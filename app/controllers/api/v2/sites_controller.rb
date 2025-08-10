class Api::V2::SitesController < ApplicationController
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
    query = query.where(faction_id: params["faction_id"]) if params["faction_id"].present?
    query = query.where(juncture_id: params["juncture_id"]) if params["juncture_id"].present?
    query = query.where("sites.name ILIKE ?", "%#{params['search']}%") if params["search"].present?
    if params["show_all"] == "true"
      query = query.where(active: [true, false, nil])
    else
      query = query.where(active: true)
    end
    # Join associations
    query = query.joins(:attunements).where(attunements: { character_id: params[:character_id] }) if params[:character_id].present?

    # Cache key
    cache_key = [
      "sites/index",
      current_campaign.id,
      sort_order,
      page,
      per_page,
      params["site_id"],
      params["fight_id"],
      params["party_id"],
      params["search"],
      params["faction_id"],
      params["autocomplete"],
      params["character_id"],
      params["show_all"],
    ].join("/")

    cached_result = Rails.cache.fetch(cache_key, expires_in: 5.minutes) do
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
    render json: cached_result
  end

  def oldindex
    @sites = current_campaign
      .sites
      .distinct
      .with_attached_image

    if params[:id].present?
      @sites = @sites.where(id: params[:id])
    end
    if params[:search].present?
      @sites = @sites.where("name ILIKE ?", "%#{params[:search]}%")
    end
    if params[:faction_id].present?
      @sites = @sites.where(faction_id: params[:faction_id])
    end
    if params[:character_id].present?
      @sites = @sites.joins(:attunements).where(attunements: { id: params[:character_id] })
    end
    if params[:user_id].present?
      @sites = @sites.joins(:characters).where(characters: { user_id: params[:user_id] })
    end

    cache_key = [
      "sites/index",
      current_campaign.id,
      sort_order,
      params[:page],
      params[:per_page],
      params[:id],
      params[:search],
      params[:user_id],
      params[:faction_id],
      params[:character_id],
    ].join("/")

    @factions = current_campaign.factions.joins(:sites).where(sites: @sites).order("factions.name").distinct

    @sites = @sites
      .select(:id, :name, :description, :campaign_id, :faction_id, :active, :created_at, :updated_at, "LOWER(sites.name) AS lower_name")
      .includes(
        { faction: [:image_attachment, :image_blob] },
        { attunements: [
          { character: [:image_attachment, :image_blob] },
        ] },
        :image_positions,
      )
      .order(Arel.sql(sort_order))

    cached_result = Rails.cache.fetch(cache_key, expires_in: 12.hours) do
      @sites = paginate(@sites, per_page: (params[:per_page] || 10), page: (params[:page] || 1))

      {
        sites: ActiveModelSerializers::SerializableResource.new(@sites, each_serializer: SiteIndexSerializer).serializable_hash,
        factions: ActiveModelSerializers::SerializableResource.new(@factions, each_serializer: FactionLiteSerializer).serializable_hash,
        meta: pagination_meta(@sites),
      }
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
      render json: { errors: @site.errors.full_messages }, status: :unprocessable_entity
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
      render json: @site
    else
      render json: { errors: @site.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @site = current_campaign.sites.find(params[:id])
    if @site.attunement_ids.any? && !params[:force]
      render json: { errors: { attunements: true  } }, status: 400 and return
    end

    if @site.attunement_ids.any? && params[:force]
      @site.attunements.destroy_all
    end

    if @site.destroy!
      render :ok
    else
      render json: { errors: @site.errors }, status: 400
    end
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
