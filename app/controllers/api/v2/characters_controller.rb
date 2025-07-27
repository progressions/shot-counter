class Api::V2::CharactersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign
  before_action :set_scoped_characters
  before_action :set_character, only: [:update, :destroy, :show, :remove_image, :sync, :pdf]

  def index
    # Define sorting parameters
    sort = params[:sort] || "created_at"
    order = params[:order] || "DESC"

    # Build safe SQL for sorting
    if sort == "type"
      sort = Arel.sql("COALESCE(action_values->>'Type', '') #{order}")
    elsif sort == "name"
      sort = Arel.sql("LOWER(characters.name) #{order}")
    elsif sort == "created_at"
      sort = Arel.sql("characters.created_at #{order}")
    else
      sort = Arel.sql("characters.#{sort} #{order}")
    end

    # Fetch characters with eager-loaded associations
    @characters = @scoped_characters
      .eager_load(
        :user,
        :faction,
        :juncture,
        :schticks,
        :advancements,
        :carries,
        :attunements,
        :sites,
        :weapons,
        image_attachment: :blob,
        user: { image_attachment: :blob },
        faction: { image_attachment: :blob },
        juncture: { image_attachment: :blob },
        sites: { image_attachment: :blob },
        weapons: { image_attachment: :blob },
        carries: { weapon: { image_attachment: :blob } },
        attunements: { site: { image_attachment: :blob } }
      )
      .order(sort)

    # Apply user_id filter if provided
    if params[:user_id]
      @characters = @characters.where(user_id: params[:user_id])
    end

    # Paginate with optimized count query
    @characters = paginate(@characters, per_page: (params[:per_page] || 15), page: (params[:page] || 1)) do |scope|
      scope.where(campaign_id: current_campaign.id).select(:id).distinct.count
    end

    # Cache factions and archetypes using paginated character IDs
    character_ids = @characters.map(&:id)
    @factions = Rails.cache.fetch("campaign/#{current_campaign.id}/factions", expires_in: 1.hour) do
      Faction.eager_load(image_attachment: :blob)
             .where(id: @scoped_characters.where(id: character_ids).pluck(:faction_id).uniq.compact)
             .order(:name)
    end

    @archetypes = Rails.cache.fetch("campaign/#{current_campaign.id}/archetypes", expires_in: 1.hour) do
      @scoped_characters.where(id: character_ids)
                        .where("action_values->>'Archetype' != ''")
                        .pluck(Arel.sql("action_values->>'Archetype'")).uniq
    end

    # Render JSON response
    render json: {
      characters: ActiveModelSerializers::SerializableResource.new(@characters, each_serializer: CharacterSerializer),
      factions: ActiveModelSerializers::SerializableResource.new(@factions, each_serializer: FactionSerializer),
      archetypes: @archetypes,
      meta: pagination_meta(@characters)
    }
  end

  def create
    @character = current_campaign.characters.create!(character_params)
    @character.user = current_user
    @character.campaign = current_campaign

    if @character.save
      # Invalidate caches to reflect new character data
      Rails.cache.delete("campaign/#{current_campaign.id}/factions")
      Rails.cache.delete("campaign/#{current_campaign.id}/archetypes")
      SyncCharacterToNotionJob.perform_later(@character.id)
      render json: CharacterSerializer.new(@character)
    else
      render json: @character.errors, status: 400
    end
  end

  def show
    render json: CharacterSerializer.new(@character)
  end

  def update
    if @character.update(character_params)
      # Invalidate caches to reflect updated character data
      Rails.cache.delete("campaign/#{current_campaign.id}/factions")
      Rails.cache.delete("campaign/#{current_campaign.id}/archetypes")
      SyncCharacterToNotionJob.perform_later(@character.id)
      render json: CharacterSerializer.new(@character)
    else
      render json: @character.errors, status: 400
    end
  end

  def destroy
    @character.carries.destroy_all
    @character.destroy!
    # Invalidate caches to reflect deleted character
    Rails.cache.delete("campaign/#{current_campaign.id}/factions")
    Rails.cache.delete("campaign/#{current_campaign.id}/archetypes")
    render json: { status: :ok }
  end

  def import
    if params[:pdf_file].present?
      # Initialize PDFtk with the path to the pdftk binary
      pdftk = PdfForms.new("/usr/local/bin/pdftk") # Adjust path as needed

      # Save uploaded PDF temporarily
      uploaded_file = params[:pdf_file]

      @character = PdfService.pdf_to_character(uploaded_file, current_campaign, { user: current_user })

      if @character.save
        # Invalidate caches to reflect new character data
        Rails.cache.delete("campaign/#{current_campaign.id}/factions")
        Rails.cache.delete("campaign/#{current_campaign.id}/archetypes")
        render json: CharacterSerializer.new(@character), status: :created
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
    NotionService.update_character_from_notion(@character)

    # Invalidate caches to reflect synced character data
    Rails.cache.delete("campaign/#{current_campaign.id}/factions")
    Rails.cache.delete("campaign/#{current_campaign.id}/archetypes")
    render json: CharacterSerializer.new(@character)
  end

  def remove_image
    @character.image.purge

    if @character.save
      # Invalidate caches to reflect updated character data
      Rails.cache.delete("campaign/#{current_campaign.id}/factions")
      Rails.cache.delete("campaign/#{current_campaign.id}/archetypes")
      render json: CharacterSerializer.new(@character)
    else
      render json: @character.errors, status: 400
    end
  end

  def pdf
    temp_path = PdfService.character_to_pdf(@character)
    filename = "#{@character.name.downcase.gsub(' ', '_')}_character_sheet.pdf"

    send_file temp_path, type: "application/pdf", disposition: "attachment", filename: filename
  end

  private

  def set_character
    @character = @scoped_characters.find(params[:id])
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
