class Api::V2::SitesController < ApplicationController
  include VisibilityFilterable
  
  before_action :authenticate_user!
  before_action :require_current_campaign

  def index
    per_page = (params["per_page"] || 15).to_i
    page = (params["page"] || 1).to_i
    selects = [
      "sites.id",
      "sites.name",
      "sites.campaign_id",
      "sites.faction_id",
      "sites.juncture_id",
      "sites.description",
      "sites.created_at",
      "sites.updated_at",
      "sites.active",
    ]
    includes = [
      :image_positions,
      image_attachment: :blob,
      faction: { image_attachment: :blob },
      juncture: { image_attachment: :blob },
      attunements: { character: { image_attachment: :blob } },
    ]
    query = current_campaign
      .sites
      .select(selects)
      .includes(includes)

    # Apply filters
    query = query.where(id: params["id"]) if params["id"].present?
    query = apply_ids_filter(query, params["ids"]) if params.key?("ids")
    query = query.where(params["faction_id"] == "__NONE__" ? "sites.faction_id IS NULL" : "sites.faction_id = ?", params["faction_id"]) if params["faction_id"].present?
    query = query.where(params["juncture_id"] == "__NONE__" ? "sites.juncture_id IS NULL" : "sites.juncture_id = ?", params["juncture_id"]) if params["juncture_id"].present?
    query = query.where("sites.name ILIKE ?", "%#{params['search']}%") if params["search"].present?
    query = query.where(apply_visibility_filter)
    # Join associations
    query = query.joins(:attunements).where(attunements: { character_id: params[:character_id] }) if params[:character_id].present?

    # Handle cache buster
    if cache_buster_requested?
      clear_resource_cache("sites", current_campaign.id)
      Rails.logger.info "🔄 Cache buster requested for sites"
    end

    # Cache key - includes cache version that changes when any entity is modified
    cache_key = [
      "sites/index",
      current_campaign.id,
      Site.cache_version_for(current_campaign.id),  # Changes when ANY sites is created/updated/deleted
      sort_order,
      page,
      per_page,
      params["id"],
      format_ids_for_cache(params["ids"]),
      params["site_id"],
      params["fight_id"],
      params["party_id"],
      params["search"],
      params["faction_id"],
      params["autocomplete"],
      params["character_id"],
      params["visibility"],
      params["show_hidden"],
    ].join("/")

    # Skip cache if cache buster is requested
    cached_result = if cache_buster_requested?
      Rails.logger.info "⚡ Skipping cache for sites index"
      sites = query.order(Arel.sql(sort_order))
      sites = paginate(sites, per_page: per_page, page: page)
      # Fetch factions
      faction_ids = sites.pluck(:faction_id).uniq.compact
      factions = Faction.where(id: faction_ids)
                        .select("factions.id", "factions.name")
                        .order("LOWER(factions.name) ASC")
      # Archetypes
      {
        "sites" => ActiveModelSerializers::SerializableResource.new(
          sites,
          each_serializer: params[:autocomplete] ? SiteAutocompleteSerializer : SiteIndexSerializer,
          adapter: :attributes
        ).serializable_hash,
        "factions" => ActiveModelSerializers::SerializableResource.new(
          factions,
          each_serializer: FactionLiteSerializer,
          adapter: :attributes
        ).serializable_hash,
        "meta" => pagination_meta(sites)
      }
    else
      Rails.cache.fetch(cache_key, expires_in: 5.minutes) do
        sites = query.order(Arel.sql(sort_order))
        sites = paginate(sites, per_page: per_page, page: page)
        # Fetch factions
        faction_ids = sites.pluck(:faction_id).uniq.compact
        factions = Faction.where(id: faction_ids)
                          .select("factions.id", "factions.name")
                          .order("LOWER(factions.name) ASC")
        # Archetypes
        {
          "sites" => ActiveModelSerializers::SerializableResource.new(
            sites,
            each_serializer: params[:autocomplete] ? SiteAutocompleteSerializer : SiteIndexSerializer,
            adapter: :attributes
          ).serializable_hash,
          "factions" => ActiveModelSerializers::SerializableResource.new(
            factions,
            each_serializer: FactionLiteSerializer,
            adapter: :attributes
          ).serializable_hash,
          "meta" => pagination_meta(sites)
        }
      end
    end
    render json: cached_result
  end

  def show
    render json: SiteSerializer.new(current_campaign.sites.find(params[:id])).serializable_hash
  end

  def create
    # Check if request is multipart/form-data with a JSON string
    if params[:site].present? && params[:site].is_a?(String)
      begin
        site_data = JSON.parse(params[:site]).symbolize_keys
      rescue JSON::ParserError
        render json: { error: "Invalid site data format" }, status: :bad_request
        return
      end
    else
      site_data = site_params.to_h.symbolize_keys
    end

    site_data = site_data.slice(:name, :description, :active, :faction_id, :juncture_id, :active)

    @site = current_campaign.sites.new(site_data)

    # Handle image attachment if present
    if params[:image].present?
      @site.image.attach(params[:image])
    end

    if @site.save
      render json: @site, status: :created
    else
      render json: { errors: @site.errors }, status: :unprocessable_content
    end
  end

  def update
    @site = current_campaign.sites.find(params[:id])

    # Handle multipart/form-data for updates if present
    if params[:site].present? && params[:site].is_a?(String)
      begin
        site_data = JSON.parse(params[:site]).symbolize_keys
      rescue JSON::ParserError
        render json: { error: "Invalid site data format" }, status: :bad_request
        return
      end
    else
      site_data = site_params.to_h.symbolize_keys
    end
    site_data = site_data.slice(:name, :description, :active, :faction_id, :character_ids, :juncture_id, :active)

    # Handle image attachment if present
    if params[:image].present?
      begin
        @site.image.purge if @site.image.attached? # Remove existing image
        @site.image.attach(params[:image])
      rescue StandardError => e
        Rails.logger.error("Error uploading to ImageKit")
      end
    end

    if @site.update(site_data)
      render json: @site.reload
    else
      render json: { errors: @site.errors }, status: :unprocessable_content
    end
  end

  def destroy
    @site = current_campaign.sites.find(params[:id])
    service = SiteDeletionService.new
    result = service.delete(@site, force: params[:force].present?)
    handle_deletion_result(result)
  end

  def remove_image
    @site = current_campaign.sites.find(params[:id])
    @site.image.purge

    if @site.save
      render json: @site
    else
      render @site.errors, status: 400
    end
  end

  private

  def site_params
    params.require(:site).permit(:name, :description, :faction_id, :juncture_id, :active, :image, character_ids: [])
  end

  def sort_order
    sort = params["sort"] || "created_at"
    order = params["order"] || "DESC"

    if sort == "name"
      "LOWER(sites.name) #{order}"
    elsif sort == "created_at"
      "sites.created_at #{order}"
    elsif sort == "updated_at"
      "sites.updated_at #{order}"
    else
      "sites.created_at DESC"
    end
  end
end
