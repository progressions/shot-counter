class Api::V2::CharactersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign
  before_action :set_scoped_characters
  before_action :set_character, only: ["update", "destroy", "show", "remove_image", "sync", "pdf"]

  def index
    sort = params["sort"] || "created_at"
    order = params["order"] || "DESC"
    per_page = (params["per_page"] || 15).to_i
    page = (params["page"] || 1).to_i

    # Define sort SQL
    if sort == "type"
      sort_sql = Arel.sql("COALESCE(action_values->>'Type', '') #{order}")
    elsif sort == "name"
      sort_sql = Arel.sql("LOWER(characters.name) #{order}")
    elsif sort == "created_at"
      sort_sql = Arel.sql("characters.created_at #{order}")
    else
      sort_sql = Arel.sql("characters.created_at DESC")
    end

    # Build includes for eager loading
    includes = [
      { user: { image_attachment: :blob } },
      { faction: { image_attachment: :blob } },
      { image_attachment: :blob }
    ]
    includes << { attunements: { site: { image_attachment: :blob } } } if params[:include]&.include?("attunements")
    includes << { carries: { weapon: { image_attachment: :blob } } } if params[:include]&.include?("carries")
    includes << { character_schticks: :schtick } if params[:include]&.include?("schticks")
    includes << :advancements if params[:include]&.include?("advancements")

    # Base query with eager loading
    characters_query = @scoped_characters.select(
      :id, :active, :created_at, :name, :defense, :impairments,
      :color, :user_id, :faction_id, :action_values
    ).includes(includes)

    # Apply filters
    characters_query = characters_query.where(faction_id: params[:faction_id]) if params[:faction_id].present?
    characters_query = characters_query.where(user_id: params[:user_id]) if params[:user_id].present?
    characters_query = characters_query.where("characters.name ILIKE ?", "%#{params[:search]}%") if params[:search].present?

    # Cache key includes all relevant params
    cache_key = [
      "characters",
      current_campaign.id,
      sort,
      order,
      page,
      per_page,
      params[:search],
      params[:user_id],
      params[:faction_id],
      params[:include]
    ].join("/")

    cached_result = Rails.cache.fetch(cache_key, expires_in: 5.minutes) do
      # Paginate characters
      characters = characters_query.order(sort_sql).page(page).per(per_page)

      # Fetch factions (without counts)
      faction_ids = characters.map(&:faction_id).uniq.compact
      factions = Faction.where(id: faction_ids)
                        .includes(image_attachment: :blob)
                        .order(:name)

      # Batch fetch party data
      party_ids = Membership.where(character_id: characters.map(&:id)).distinct.pluck(:party_id)
      parties = Party.where(id: party_ids)
                     .includes(
                       memberships: [
                         :character,
                         { vehicle: { image_attachment: :blob } }
                       ],
                       image_attachment: :blob
                     )

      # Batch archetypes
      archetypes = characters.map { |c| c.action_values["Archetype"] }.compact.sort

      # Serialize
      {
        "characters" => ActiveModelSerializers::SerializableResource.new(
          characters,
          each_serializer: CharacterIndexSerializer,
          scope: { parties: parties, params: params }
        ).serializable_hash,
        "factions" => ActiveModelSerializers::SerializableResource.new(
          factions,
          each_serializer: FactionSerializer
        ).serializable_hash,
        "archetypes" => archetypes,
        "meta" => pagination_meta(characters)
      }.to_json
    end

    render json: JSON.parse(cached_result)
  end

  def names
    # Build cache key with relevant params
    cache_key = [
      "characters_autocomplete",
      current_campaign.id,
      params[:search],
      params[:faction_id],
      params[:user_id]
    ].join("/")

    # Cache the response for 5 minutes
    results = Rails.cache.fetch(cache_key, expires_in: 5.minutes) do
      # Base query: select only id and name
      query = @scoped_characters.select(:id, :name)

      # Apply filters
      query = query.where("characters.name ILIKE ?", "%#{params[:search]}%") if params[:search].present?
      query = query.where(faction_id: params[:faction_id]) if params[:faction_id].present?
      query = query.where(user_id: params[:user_id]) if params[:user_id].present?

      # Limit results (e.g., 20 for autocomplete)
      query.order("LOWER(characters.name) ASC")
           .limit(20)
           .map { |c| { "id" => c.id, "name" => c.name } }
           .to_json
    end

    render json: JSON.parse(results)
  end

  def create
    @character = current_campaign.characters.create!(character_params)
    @character.user = current_user
    @character.campaign = current_campaign

    if @character.save
      Rails.cache.delete_matched("characters/#{current_campaign.id}/*")
      SyncCharacterToNotionJob.perform_later(@character.id)
      render json: @character
    else
      render status: 400
    end
  end

  def show
    render json: @character
  end

  def update
    if @character.update(character_params)
      Rails.cache.delete_matched("characters/#{current_campaign.id}/*")
      SyncCharacterToNotionJob.perform_later(@character.id)
      render json: @character
    else
      render @character.errors, status: 400
    end
  end

  def destroy
    @character.carries.destroy_all
    @character.memberships.destroy_all
    @character.destroy!
    Rails.cache.delete_matched("characters/#{current_campaign.id}/*")
    render json: { message: "Character deleted successfully" }, status: :ok
  end

  def import
    if params["pdf_file"].present?
      # Initialize PDFtk with the path to the pdftk binary
      pdftk = PdfForms.new("/usr/local/bin/pdftk") # Adjust path as needed

      # Save uploaded PDF temporarily
      uploaded_file = params["pdf_file"]

      @character = PdfService.pdf_to_character(uploaded_file, current_campaign, { user: current_user })

      if @character.save
        Rails.cache.delete_matched("characters/#{current_campaign.id}/*")
        render json: @character, status: :created
      else
        Rails.logger.error("Character import failed: #{@character.errors.full_messages.join(', ')}")
        render json: @character.errors, status: :unprocessable_entity
      end
    else
      @character = Character.new
      render json: { error: "No PDF file provided" }, status: :bad_request
    end
  end

  def sync
    if NotionService.update_character_from_notion(@character)
      Rails.cache.delete_matched("characters/#{current_campaign.id}/*")
      render json: @character.reload
    else
      render json: { error: "Notion sync failed" }, status: :unprocessable_entity
    end
  end

  def remove_image
    if @character.image.attached?
      @character.image.purge
      if @character.save
        Rails.cache.delete_matched("characters/#{current_campaign.id}/*")
        render json: @character
      else
        render json: @character.errors, status: :unprocessable_entity
      end
    else
      render json: @character
    end
  end

  def pdf
    temp_path = PdfService.character_to_pdf(@character)
    filename = "#{@character.name.downcase.gsub(' ', '_')}_character_sheet.pdf"

    send_file temp_path, type: "application/pdf", disposition: "attachment", filename: filename
  end

  private

  def set_character
    @character = @scoped_characters.find(params["id"])
  end

  def set_scoped_characters
    @scoped_characters = current_campaign.characters
  end

  def character_params
    params
      .require(:character)
      .permit(:name, :defense, :impairments, :color, :notion_page_id,
              :user_id, :active, :faction_id, :image, :task, :juncture_id, :wealth,
              action_values: {},
              description: Character::DEFAULT_DESCRIPTION.keys,
              schticks: [], skills: params.fetch(:character, {}).fetch(:skills, {}).keys || {})
  end
end
