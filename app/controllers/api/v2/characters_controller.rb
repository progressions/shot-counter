class Api::V2::CharactersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign
  before_action :set_scoped_characters
  before_action :set_character, only: [:update, :destroy, :remove_image, :sync, :pdf, :duplicate]

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

  # Base query with minimal fields and preload
  characters_query = @scoped_characters.select(
    "characters.id",
    "characters.name",
    "characters.image_url",
    "characters.faction_id",
    "characters.action_values",
    "characters.description",
    "characters.created_at",
    "characters.updated_at",
    "characters.skills",
  ).includes(
    :image_positions,
    image_attachment: :blob,
    schticks: { image_attachment: :blob },
  )

  # Apply filters
  characters_query = characters_query.where(faction_id: params["faction_id"]) if params["faction_id"].present?
  characters_query = characters_query.where(user_id: params["user_id"]) if params["user_id"].present?
  characters_query = characters_query.where("characters.name ILIKE ?", "%#{params['search']}%") if params["search"].present?
  characters_query = characters_query.where("action_values->>'Type' = ?", params["type"]) if params["type"].present?
  characters_query = characters_query.where("action_values->>'Archetype' = ?", params["archetype"]) if params["archetype"].present?
  characters_query = characters_query.where("is_template = ?", true) if params["is_template"].present? && params["is_template"] == "true"
  if params[:party_id].present?
    characters_query = characters_query.joins(:parties).where(parties: { id: params[:party_id] })
  end

  # Cache key
  cache_key = [
    "characters/index",
    current_campaign.id,
    sort,
    order,
    page,
    per_page,
    params["search"],
    params["user_id"],
    params["faction_id"],
    params["type"],
    params["archetype"],
  ].join("/")

  cached_result = Rails.cache.fetch(cache_key, expires_in: 5.minutes) do
    characters = characters_query.order(sort_sql).page(page).per(per_page)

    # Fetch factions
    faction_ids = characters.pluck(:faction_id).uniq.compact
    factions = Faction.where(id: faction_ids)
                      .select("factions.id", "factions.name")
                      .order("LOWER(factions.name) ASC")

    # Archetypes
    archetypes = characters.map { |c| c.action_values["Archetype"] }.compact.uniq.sort

    {
      "characters" => ActiveModelSerializers::SerializableResource.new(
        characters,
        each_serializer: CharacterIndexLiteSerializer,
        adapter: :attributes
      ).serializable_hash,
      "factions" => ActiveModelSerializers::SerializableResource.new(
        factions,
        each_serializer: FactionLiteSerializer,
        adapter: :attributes
      ).serializable_hash,
      "archetypes" => archetypes,
      "meta" => pagination_meta(characters)
    }.to_json
  end

  render json: JSON.parse(cached_result)
end

  def autocomplete
    characters = current_campaign.characters.active
      .select("characters.id", "characters.name", "characters.faction_id", "characters.action_values")

    if params["faction_id"].present?
      characters = characters.where(faction_id: params["faction_id"])
    end

    if params["type"].present?
      characters = characters.where("action_values ->> 'Type' = ?", params["type"])
    end

    if params["archetype"].present?
      characters = characters.where("action_values ->> 'Archetype' = ?", params["archetype"])
    end

    characters = characters.order("LOWER(characters.name) #{params['order'] || 'asc'}")
      .limit(params["per_page"] || 75)
      .offset((params["page"]&.to_i || 0) * (params["per_page"]&.to_i || 75))

    # Get unique factions based on matching characters
    faction_ids = characters.pluck(:faction_id).uniq.compact
    factions = Faction.where(id: faction_ids)
                      .select("factions.id", "factions.name")
                      .order("LOWER(factions.name) ASC")

    archetypes = characters.map { |c| c.action_values["Archetype"] }.compact.uniq.sort

    render json: {
      characters: ActiveModelSerializers::SerializableResource.new(
        characters,
        each_serializer: CharacterAutocompleteSerializer,
        adapter: :attributes
      ),
      factions: ActiveModelSerializers::SerializableResource.new(
        factions,
        each_serializer: FactionAutocompleteSerializer,
        adapter: :attributes
      ),
      archetypes: archetypes
    }
  end

  def create
    # Check if request is multipart/form-data with a JSON string
    if params[:character].present? && params[:character].is_a?(String)
      begin
        character_data = JSON.parse(params[:character]).symbolize_keys
      rescue JSON::ParserError
        render json: { error: "Invalid character data format" }, status: :bad_request
        return
      end
    else
      character_data = character_params.to_h.symbolize_keys
    end

    character_data = character_data.slice(:name, :description, :active, :character_ids, :party_ids, :site_ids, :juncture_ids, :schtick_ids, :weapon_ids)

    @character = current_campaign.characters.new(character_data)

    # Handle image attachment if present
    if params[:image].present?
      @character.image.attach(params[:image])
    end

    if @character.save
      render json: @character, status: :created
    else
      render json: { errors: @character.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    @character = current_campaign.characters.find(params[:id])

    # Handle multipart/form-data for updates if present
    if params[:character].present? && params[:character].is_a?(String)
      begin
        character_data = JSON.parse(params[:character]).symbolize_keys
      rescue JSON::ParserError
        render json: { error: "Invalid character data format" }, status: :bad_request
        return
      end
    else
      character_data = character_params.to_h.symbolize_keys
    end
    character_data = character_data.slice(:name, :description, :active, :character_ids, :party_ids, :site_ids, :juncture_ids, :schtick_ids, :action_values, :skills, :weapon_ids)

    # Handle image attachment if present
    if params[:image].present?
      begin
        @character.image.purge if @character.image.attached? # Remove existing image
        @character.image.attach(params[:image])
      rescue StandardError => e
        Rails.logger.error("Error uploading to ImageKit")
      end
    end

    if @character.update(character_data)
      Rails.cache.delete_matched("characters/#{current_campaign.id}/*")
      SyncCharacterToNotionJob.perform_later(@character.id)

      render json: @character, serializer: CharacterSerializer, status: :ok
    else
      render json: { errors: @character.errors }, status: :unprocessable_entity
    end
  end

  def show
    @character = current_campaign.characters.includes(
      :image_positions,
      user: { image_attachment: :blob },
      faction: { image_attachment: :blob },
      image_attachment: :blob,
      attunements: { site: { image_attachment: :blob } },
      carries: { weapon: { image_attachment: :blob } },
      character_schticks: :schtick,
      advancements: [],
    ).find(params[:id])

    render json: @character
  end

  def destroy
    @character.carries.destroy_all
    @character.memberships.destroy_all
    @character.destroy!
    Rails.cache.delete_matched("characters/#{current_campaign.id}/*")
    render json: { message: "Character deleted successfully" }, status: :ok
  end

  def duplicate
    @new_character = CharacterDuplicatorService.duplicate_character(@character, current_user)
    @new_character.is_template = false

    if @new_character.save
      Rails.cache.delete_matched("characters/#{current_campaign.id}/*")
      SyncCharacterToNotionJob.perform_later(@new_character.id)
      render json: @new_character, status: :created
    else
      Rails.logger.error("Character duplication failed: #{@new_character.errors.full_messages.join(', ')}")
      render json: @new_character.errors, status: :unprocessable_entity
    end
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
              schtick_ids: [], weapon_ids: [],
              action_values: {},
              description: Character::DEFAULT_DESCRIPTION.keys,
              schticks: [], skills: params.fetch(:character, {}).fetch(:skills, {}).keys || {})
  end
end
