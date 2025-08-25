class Api::V2::CampaignsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_gamemaster_or_admin, only: [:create, :update, :destroy, :remove_image]
  before_action :set_campaign, only: [:show, :update, :remove_image]
  before_action :set_campaign_for_set, only: [:set]

  def show
    unless @campaign
      render json: { error: "Record not found or unauthorized" }, status: :not_found
      return
    end
    
    campaign_to_show = params[:id] == "current" ? current_campaign : @campaign
    cache_key = "campaign/#{campaign_to_show.id}/#{params[:id] == 'current' ? 'current' : 'show'}"
    Rails.logger.info("Checking cache for key: #{cache_key}")
    campaign_data = Rails.cache.fetch(cache_key, expires_in: 5.minutes) do
      Rails.logger.info("Cache miss for #{cache_key}, generating data")
      ActiveModelSerializers::SerializableResource.new(
        campaign_to_show,
        serializer: CampaignSerializer,
        adapter: :attributes
      ).serializable_hash
    end
    render json: campaign_data
  end

  def index
    Rails.logger.info "🔍 Campaigns#index called by user: #{current_user.email}"
    Rails.logger.info "   Params: #{params.inspect}"
    Rails.logger.info "   User is gamemaster: #{current_user.gamemaster?}"
    
    # Handle cache buster - campaigns use user-specific cache
    if cache_buster_requested?
      clear_resource_cache("campaigns", current_user.id)
      Rails.logger.info "🔄 Cache buster requested for campaigns"
    end
    
    per_page = (params["per_page"] || 15).to_i
    page = (params["page"] || 1).to_i
    selects = [
      "campaigns.id",
      "campaigns.user_id",
      "campaigns.name",
      "campaigns.description",
      "campaigns.created_at",
      "campaigns.updated_at",
      "campaigns.active",
    ]
    # For index view, we only need lightweight data - no eager loading
    # Characters and vehicles counts will be calculated in the serializer
    includes = [
      image_attachment: :blob,
    ]
    query = if current_user.gamemaster? || current_user.admin?
              Rails.logger.info "   Getting gamemaster campaigns"
              current_user.campaigns
            else
              Rails.logger.info "   Getting player campaigns"
              current_user.player_campaigns
            end
    Rails.logger.info "   Initial query count: #{query.count}"
    
    # Apply filters before select
    query = query.where(id: params["id"]) if params["id"].present?
    if params.key?("ids")
      query = params["ids"].blank? ? query.where(id: nil) : query.where(id: params["ids"].split(","))
    end
    query = query.where("campaigns.name ILIKE ?", "%#{params['search']}%") if params["search"].present?
    if params["show_all"] == "true"
      Rails.logger.info "   Showing all campaigns (active and inactive)"
      query = query.where(active: [true, false, nil])
    else
      Rails.logger.info "   Filtering to active campaigns only"
      query = query.where(active: true)
    end
    Rails.logger.info "   After active filter count: #{query.count}"
    
    # Apply select and includes after filtering
    query = query.select(selects).includes(includes)
    query = query.joins(:characters).where(characters: { id: params[:character_id] }) if params[:character_id].present?
    query = query.joins(:vehicles).where(vehicles: { id: params[:vehicle_id] }) if params[:vehicle_id].present?
    # Cache key
    cache_key = [
      "campaigns/index",
      current_user.id,
      sort_order,
      page,
      per_page,
      params["search"],
      params["autocomplete"],
      params["character_id"],
      params["vehicle_id"],
      params["show_all"],
    ].join("/")
    
    # Skip cache if cache buster is requested
    cached_result = if cache_buster_requested?
      Rails.logger.info "⚡ Skipping cache for campaigns index"
      campaigns = query.order(Arel.sql(sort_order))
      campaigns = paginate(campaigns, per_page: per_page, page: page)
      {
        "campaigns" => ActiveModelSerializers::SerializableResource.new(
          campaigns,
          each_serializer: params[:autocomplete] ? CampaignAutocompleteSerializer : CampaignIndexLiteSerializer,
          adapter: :attributes
        ).serializable_hash,
        "meta" => pagination_meta(campaigns)
      }
    else
      Rails.cache.fetch(cache_key, expires_in: 5.minutes) do
        campaigns = query.order(Arel.sql(sort_order))
        campaigns = paginate(campaigns, per_page: per_page, page: page)
        {
          "campaigns" => ActiveModelSerializers::SerializableResource.new(
            campaigns,
            each_serializer: params[:autocomplete] ? CampaignAutocompleteSerializer : CampaignIndexLiteSerializer,
            adapter: :attributes
          ).serializable_hash,
          "meta" => pagination_meta(campaigns)
        }
      end
    end
    
    render json: cached_result
  end

  def create
    if params[:campaign].present? && params[:campaign].is_a?(String)
      begin
        campaign_data = JSON.parse(params[:campaign]).symbolize_keys
      rescue JSON::ParserError
        render json: { error: "Invalid campaign data format" }, status: :bad_request
        return
      end
    else
      campaign_data = campaign_params.to_h.symbolize_keys
    end
    campaign_data = campaign_data.slice(:name, :description, :active, :user_ids)
    @campaign = current_user.campaigns.new(campaign_data)
    if params[:image].present?
      @campaign.image.attach(params[:image])
    end
    if @campaign.save
      # Seed the campaign with template content (unless it's a master template)
      unless @campaign.is_master_template?
        CampaignSeederJob.perform_later(@campaign.id)
      end
      
      # Clear cache after creating a new campaign
      clear_campaign_cache_for_user(current_user)
      render json: @campaign, status: :created
    else
      render json: { errors: @campaign.errors }, status: :unprocessable_entity
    end
  end

  def update
    unless @campaign
      render json: { error: "Record not found or unauthorized" }, status: :not_found
      return
    end
    if params[:campaign].present? && params[:campaign].is_a?(String)
      begin
        campaign_data = JSON.parse(params[:campaign]).symbolize_keys
      rescue JSON::ParserError
        render json: { error: "Invalid campaign data format" }, status: :bad_request
        return
      end
    else
      campaign_data = campaign_params.to_h.symbolize_keys
    end
    campaign_data = campaign_data.slice(:name, :description, :active, :user_ids)
    if params[:image].present?
      @campaign.image.purge if @campaign.image.attached?
      @campaign.image.attach(params[:image])
    end
    if @campaign.update(campaign_data)
      # Clear cache after update (especially important for active status changes)
      clear_campaign_cache_for_user(current_user)
      render json: @campaign
    else
      render json: { errors: @campaign.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    @campaign = (current_user.campaigns.find_by(id: params[:id]) if current_user.gamemaster?) || (Campaign.find_by(id: params[:id]) if current_user.admin?)
    unless @campaign
      render json: { error: "Record not found or unauthorized" }, status: :not_found
      return
    end
    if @campaign.id == current_campaign&.id
      render json: { error: "Cannot destroy the current campaign" }, status: :unauthorized
      return
    end
    if (@campaign.characters.any? || @campaign.vehicles.any? || @campaign.factions.any? || @campaign.junctures.any? || @campaign.fights.any?) && !params[:force]
      render json: { errors: { associations: true } }, status: :bad_request
      return
    end
    if params[:force]
      @campaign.characters.update_all(campaign_id: nil)
      @campaign.vehicles.update_all(campaign_id: nil)
      @campaign.factions.update_all(campaign_id: nil)
      @campaign.junctures.update_all(campaign_id: nil)
      @campaign.fights.update_all(campaign_id: nil)
    end
    if @campaign.destroy!
      render :ok
    else
      render json: { errors: @campaign.errors }, status: :bad_request
    end
  end

  def current
    campaign = current_campaign
    if campaign
      render json: campaign
    else
      render json: nil
    end
  end

  def set
    if params[:id].nil?
      # Clear current campaign
      save_current_campaign(nil)
      render json: nil
    else
      save_current_campaign(@campaign)
      
      # Track onboarding milestone for first campaign activation
      puts "=" * 80
      puts "🔍 CAMPAIGN ACTIVATION DEBUG:"
      puts "  - User: #{current_user.email}"
      puts "  - Campaign: #{@campaign.name}"
      puts "  - User has onboarding_progress: #{!!current_user.onboarding_progress}"
      puts "  - first_campaign_activated_at: #{current_user.onboarding_progress&.first_campaign_activated_at}"
      
      if current_user.onboarding_progress && !current_user.onboarding_progress.first_campaign_activated_at
        puts "  - ✅ Setting first_campaign_activated_at milestone!"
        current_user.onboarding_progress.update!(first_campaign_activated_at: Time.current)
        puts "  - ✅ Milestone set to: #{current_user.onboarding_progress.reload.first_campaign_activated_at}"
      else
        puts "  - ⚠️  Milestone already set or no onboarding progress"
      end
      puts "=" * 80
      
      render json: @campaign
    end
  end

  def remove_image
    unless @campaign
      render json: { error: "Record not found or unauthorized" }, status: :not_found
      return
    end
    @campaign.image.purge if @campaign.image.attached?
    if @campaign.save
      render json: @campaign
    else
      render json: { errors: @campaign.errors }, status: :unprocessable_entity
    end
  end

  private

  def require_gamemaster_or_admin
    unless current_user.gamemaster? || current_user.admin?
      render json: { error: "Gamemaster or admin access required" }, status: :forbidden
      return
    end
  end

  def set_campaign
    if params[:id] == "current"
      @campaign = current_campaign
    else
      @campaign = (current_user.campaigns.find_by(id: params[:id]) if current_user.gamemaster?) || (Campaign.find_by(id: params[:id]) if current_user.admin?) || current_user.player_campaigns.find_by(id: params[:id])
    end
  end

  def set_campaign_for_set
    # For the set method, allow nil id to clear current campaign
    if params[:id].nil?
      @campaign = nil
    else
      set_campaign
    end
  end

  def campaign_params
    params.require(:campaign).permit(:name, :description, :image, :active, user_ids: [])
  end

  def sort_order
    sort = params["sort"] || "created_at"
    order = params["order"] || "DESC"
    if sort == "name"
      "LOWER(campaigns.name) #{order}"
    elsif sort == "created_at"
      "campaigns.created_at #{order}"
    elsif sort == "updated_at"
      "campaigns.updated_at #{order}"
    else
      "campaigns.created_at DESC"
    end
  end

  def clear_campaign_cache_for_user(user)
    # Clear ALL campaign index cache entries for this user
    # We need to clear all possible combinations of sort, page, per_page, etc.
    
    # Clear cache for all common sort orders
    ["created_at desc", "created_at asc", "name asc", "name desc", "updated_at desc", "updated_at asc",
     "LOWER(campaigns.name) asc", "LOWER(campaigns.name) desc", 
     "campaigns.created_at desc", "campaigns.created_at asc",
     "campaigns.updated_at desc", "campaigns.updated_at asc"].each do |sort_order|
      # Clear for different page numbers (1-10 should cover most cases)
      (1..10).each do |page_num|
        # Clear for common per_page values (10, 15, 25)
        [10, 15, 25].each do |per_page_val|
          # Clear both with and without show_all
          [nil, "true", "false"].each do |show_all_val|
            cache_key = [
              "campaigns/index",
              user.id,
              sort_order,
              page_num,
              per_page_val,
              nil, # search
              nil, # autocomplete
              nil, # character_id
              nil, # vehicle_id
              show_all_val, # show_all
            ].join("/")
            Rails.cache.delete(cache_key)
          end
        end
      end
    end
    
    # Also try to clear with a wildcard pattern if the cache store supports it
    begin
      Rails.cache.delete_matched("campaigns/index/#{user.id}/*")
    rescue => e
      Rails.logger.info "Cache delete_matched not supported: #{e.message}"
    end
    
    Rails.logger.info "🗑️ Cleared campaign cache for user #{user.email}"
  end
end
