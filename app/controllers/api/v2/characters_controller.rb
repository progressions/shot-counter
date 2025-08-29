class Api::V2::CharactersController < ApplicationController
  include VisibilityFilterable
  
  before_action :authenticate_user!
  before_action :require_current_campaign
  before_action :set_scoped_characters
  before_action :set_character, only: [:update, :destroy, :remove_image, :sync, :pdf]
  before_action :set_character_for_duplicate, only: [:duplicate]

  def index
  per_page = (params["per_page"] || 15).to_i
  page = (params["page"] || 1).to_i
  selects = [
    "characters.id",
    "characters.user_id",
    "characters.task",
    "characters.name",
    "characters.faction_id",
    "characters.juncture_id",
    "characters.action_values",
    "characters.description",
    "characters.created_at",
    "characters.updated_at",
    "characters.skills",
    "characters.active",
    "characters.is_template"
  ]
  includes = [
    :image_positions,
    image_attachment: :blob,
    faction: { image_attachment: :blob },
    juncture: { image_attachment: :blob },
  ]
  query = @scoped_characters
    .select(selects)
    .includes(includes)
    .where(apply_visibility_filter)
    
  # Apply template filtering with security enforcement
  # Support both new template_filter parameter and legacy is_template parameter
  if params["template_filter"].present?
    template_filter = apply_template_filter(params["template_filter"])
  elsif params["is_template"].present?
    # Legacy parameter support - convert to new format
    template_filter = apply_template_filter(params["is_template"] == "true" ? "templates" : "non-templates")
  else
    # Default to non-templates
    template_filter = apply_template_filter(nil)
  end
  query = query.where(template_filter)

  # Apply filters
  query = query.where(id: params["id"]) if params["id"].present?
  query = params["ids"].blank? ? query.where(id: nil) : query.where(id: params["ids"].split(",")) if params["ids"]
  query = query.where(params["faction_id"] == "__NONE__" ? "characters.faction_id IS NULL" : { faction_id: params["faction_id"] }) if params["faction_id"].present?
  query = query.where(params["juncture_id"] == "__NONE__" ? "characters.juncture_id IS NULL" : { juncture_id: params["juncture_id"] }) if params["juncture_id"].present?
  query = query.where(user_id: params["user_id"]) if params["user_id"].present?
  query = query.where("characters.name ILIKE ?", "%#{params['search']}%") if params["search"].present?
  query = query.where("action_values->>'Type' = ?", params["character_type"]) if params["character_type"].present?
  query = query.where("action_values->>'Archetype' = ?", params["archetype"] == "__NONE__" ? "" : params["archetype"]) if params["archetype"].present?
  query = query.joins(:memberships).where(memberships: { party_id: params[:party_id] }) if params[:party_id].present?
  query = query.joins(:shots).where(shots: { fight_id: params[:fight_id] }) if params[:fight_id].present?
  query = query.joins(:attunements).where(attunements: { site_id: params[:site_id] }) if params[:site_id].present?

  # Handle cache buster
  if cache_buster_requested?
    clear_resource_cache("characters", current_campaign.id)
    Rails.logger.info "🔄 Cache buster requested for characters"
  end

  cache_key = [
    "characters/index",
    current_campaign.id,
      Character.cache_version_for(current_campaign.id),  # Changes when ANY character is created/updated/deleted
    sort_order,
    page,
    per_page,
    params["site_id"],
    params["fight_id"],
    params["party_id"],
    params["search"],
    params["user_id"],
    params["faction_id"],
    params["type"],
    params["archetype"],
    params["template_filter"],
    params["visibility"],
    params["show_hidden"],
    params["autocomplete"]
  ].join("/")

  # Skip cache if cache buster is requested
  cached_result = if cache_buster_requested?
    Rails.logger.info "⚡ Skipping cache for characters index"
    characters = query.order(Arel.sql(sort_order))
    characters = paginate(characters, per_page: per_page, page: page)
    factions = Faction.where(id: characters.map(&:faction_id).uniq.compact)
                      .select("factions.id", "factions.name")
                      .order("LOWER(factions.name) ASC")
    archetypes = characters.map { |c| c.action_values["Archetype"] }.compact.uniq.reject(&:blank?).sort
    {
      "characters" => ActiveModelSerializers::SerializableResource.new(
        characters,
        each_serializer: params[:autocomplete] ? CharacterAutocompleteSerializer : CharacterIndexLiteSerializer,
        adapter: :attributes
      ).serializable_hash,
      "factions" => ActiveModelSerializers::SerializableResource.new(
        factions,
        each_serializer: FactionLiteSerializer,
        adapter: :attributes
      ).serializable_hash,
      "archetypes" => archetypes,
      "meta" => pagination_meta(characters)
    }
  else
    Rails.cache.fetch(cache_key, expires_in: 5.minutes) do
      characters = query.order(Arel.sql(sort_order))
      characters = paginate(characters, per_page: per_page, page: page)
      factions = Faction.where(id: characters.map(&:faction_id).uniq.compact)
                        .select("factions.id", "factions.name")
                        .order("LOWER(factions.name) ASC")
      archetypes = characters.map { |c| c.action_values["Archetype"] }.compact.uniq.reject(&:blank?).sort
      {
        "characters" => ActiveModelSerializers::SerializableResource.new(
          characters,
          each_serializer: params[:autocomplete] ? CharacterAutocompleteSerializer : CharacterIndexLiteSerializer,
          adapter: :attributes
        ).serializable_hash,
        "factions" => ActiveModelSerializers::SerializableResource.new(
          factions,
          each_serializer: FactionLiteSerializer,
          adapter: :attributes
        ).serializable_hash,
        "archetypes" => archetypes,
        "meta" => pagination_meta(characters)
      }
    end
  end

  render json: cached_result
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

    character_data = character_data.slice(:name, :description, :active, :juncture_id, :character_ids, :party_ids, :site_ids, :juncture_ids, :schtick_ids, :weapon_ids, :faction_id, :skills, :wealth)

    @character = current_campaign.characters.new(character_data)

    # Handle image attachment if present
    if params[:image].present?
      @character.image.attach(params[:image])
    end

    if @character.save
      render json: @character, serializer: CharacterSerializer, status: :created
    else
      render json: { errors: @character.errors }, status: :unprocessable_entity
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
    
    # Check authorization for owner reassignment
    if character_data[:user_id].present? && character_data[:user_id].to_s != @character.user_id.to_s
      unless can_reassign_owner?
        render json: { error: "Not authorized to reassign character ownership" }, status: :forbidden
        return
      end
    end
    
    character_data = character_data.slice(:name, :description, :active, :character_ids, :party_ids, :site_ids, :juncture_ids, :schtick_ids, :action_values, :skills, :weapon_ids, :juncture_id, :faction_id, :wealth, :user_id)

    # Handle image attachment if present
    if params[:image].present?
      begin
        @character.image.purge if @character.image.attached? # Remove existing image
        @character.image.attach(params[:image])
      rescue StandardError => e
        Rails.logger.error("Error uploading to ImageKit: #{e.message}")
      end
    end

    if @character.update(character_data)
      SyncCharacterToNotionJob.perform_later(@character.id)
      render json: @character.reload, serializer: CharacterSerializer, status: :ok
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
      memberships: { party: { image_attachment: :blob } },
      attunements: { site: { image_attachment: :blob } },
      carries: { weapon: { image_attachment: :blob } },
      character_schticks: :schtick,
      advancements: [],
    ).find(params[:id])

    render json: @character, serializer: CharacterSerializer, status: :ok
  end

  def destroy
    service = CharacterDeletionService.new
    result = service.delete(@character, force: params[:force].present?)
    handle_deletion_result(result)
  end

  def duplicate
    @new_character = CharacterDuplicatorService.duplicate_character(@character, current_user, current_campaign)
    @new_character.is_template = false

    if @new_character.save
      # Apply associations (schticks, weapons, etc.) after save
      CharacterDuplicatorService.apply_associations(@new_character)
      
      SyncCharacterToNotionJob.perform_later(@new_character.id)
      render json: @new_character, status: :created
    else
      Rails.logger.error("Character duplication failed: #{@new_character.errors.full_messages.join(', ')}")
      render json: @new_character.errors, status: :unprocessable_entity
    end
  end

  def import
    if params["pdf_file"].present?
      uploaded_file = params["pdf_file"]

      @character = PdfService.pdf_to_character(uploaded_file, current_campaign, { user: current_user })

      if @character.save
        # Now assign the pending weapons and schticks after character is saved
        pending_weapons = @character.instance_variable_get(:@pending_weapons) || []
        pending_schticks = @character.instance_variable_get(:@pending_schticks) || []
        
        # Filter out any weapons/schticks that are already associated to avoid duplicates
        new_weapons = pending_weapons - @character.weapons
        new_schticks = pending_schticks - @character.schticks
        
        @character.weapons += new_weapons if new_weapons.any?
        @character.schticks += new_schticks if new_schticks.any?
        
        render json: @character, status: :created
      else
        Rails.logger.error("Character import failed: #{@character.errors.full_messages.join(', ')}")
        render json: @character.errors, status: :unprocessable_entity
      end
    else
      render json: { error: "No PDF file provided" }, status: :bad_request
    end
  rescue StandardError => e
    render json: { error: "Failed to import character: #{e.message}" }, status: :unprocessable_entity
  end

  def sync
    if NotionService.update_character_from_notion(@character)
      render json: @character.reload
    else
      render json: { error: "Notion sync failed" }, status: :unprocessable_entity
    end
  end

  def remove_image
    if @character.image.attached?
      @character.image.purge
      if @character.save
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

  def apply_template_filter(filter_param)
    # Allow users to access templates in their own campaigns for character creation
    # Templates are already scoped to current_campaign, so this is safe
    case filter_param
    when "templates"
      { is_template: true }
    when "all"
      {} # No filter on is_template, show all
    when "non-templates", nil, ""
      { is_template: [false, nil] }
    else
      # Invalid value defaults to non-templates
      Rails.logger.info "Invalid template_filter value: #{filter_param}, defaulting to non-templates"
      { is_template: [false, nil] }
    end
  end

  def set_character
    @character = @scoped_characters.find(params["id"])
  end
  
  def set_character_for_duplicate
    # For duplication, we need to allow templates from any campaign
    # First try to find in current campaign
    @character = current_campaign.characters.find_by(id: params["id"])
    
    # If not found and it might be a template, look across all campaigns the user has access to
    if @character.nil?
      # Find character templates that are accessible
      @character = Character.where(id: params["id"], is_template: true).first
      
      # Verify the user has permission to duplicate this template
      if @character && !can_duplicate_character?(@character)
        render json: { error: "Not authorized to duplicate this character" }, status: :forbidden
        return
      end
    end
    
    # If still not found, return error
    if @character.nil?
      render json: { error: "Character not found" }, status: :not_found
    end
  end

  def set_scoped_characters
    @scoped_characters = current_campaign.characters
  end
  
  def can_duplicate_character?(character)
    # Allow duplication if:
    # 1. User is admin
    # 2. Character is a template
    # 3. Character belongs to a campaign the user is a member of
    return true if current_user.admin?
    return true if character.is_template?
    
    # Check if user is member of the character's campaign
    character.campaign.users.include?(current_user)
  end
  
  def can_reassign_owner?
    # Admin can reassign any character
    return true if current_user.admin?
    
    # Gamemaster can reassign characters in their campaign
    return true if current_campaign.user == current_user
    
    false
  end

  def character_params
    params
      .require(:character)
      .permit(:name, :defense, :impairments, :color, :notion_page_id,
              :user_id, :active, :faction_id, :image, :task, :juncture_id, :wealth,
              schtick_ids: [], weapon_ids: [], site_ids: [], party_ids: [],
              action_values: {},
              description: Character::DEFAULT_DESCRIPTION.keys,
              schticks: [], skills: {})
  end

  def sort_order
    sort = params["sort"] || "created_at"
    order = params["order"] || "DESC"
    if sort == "type"
      "LOWER(COALESCE(action_values->>'Type', '')) #{order}, LOWER(characters.name), characters.id"
    elsif sort == "archetype"
      "LOWER(COALESCE(action_values->>'Archetype', '')) #{order}, LOWER(characters.name), characters.id"
    elsif sort == "name"
      "LOWER(characters.name) #{order}, characters.id"
    elsif sort == "created_at"
      "characters.created_at #{order}, characters.id"
    elsif sort == "updated_at"
      "characters.updated_at #{order}, characters.id"
    else
      "characters.created_at DESC, characters.id"
    end
  end
end
