class Api::V2::CharactersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign
  before_action :set_scoped_characters
  before_action :set_character, only: ["update", "destroy", "show", "remove_image", "sync", "pdf"]

  def index
    sort = params["sort"] || "created_at"
    order = params["order"] || "DESC"

    if sort == "type"
      sort = Arel.sql("COALESCE(action_values->>'Type', '') #{order}")
    elsif sort == "name"
      sort = Arel.sql("LOWER(characters.name) #{order}")
    elsif sort == "created_at"
      sort = Arel.sql("characters.created_at #{order}")
   else
      sort = Arel.sql("characters.created_at DESC")
    end

    cache_key = "characters/#{current_campaign.id}/#{sort}/#{order}/#{params[:page]}/#{params[:per_page]}/#{params[:search]}/#{params[:user_id]}"
    cached_result = Rails.cache.fetch(cache_key, expires_in: 5.minutes) do
      includes = [{ user: { image_attachment: :blob } }, { faction: { image_attachment: :blob } }, image_attachment: :blob]
      includes << { attunements: :site } if params[:include]&.include?("attunements")
      includes << { carries: :weapon } if params[:include]&.include?("carries")
      includes << { character_schticks: :schtick } if params[:include]&.include?("schticks")
      includes << :advancements if params[:include]&.include?("advancements")

      @characters = @scoped_characters.select(:id, :active, :created_at, :name, :defense, :impairments, :color, :user_id, :faction_id, :action_values).includes(includes).order(sort)
      @characters = @characters.where(user_id: params[:user_id]) if params[:user_id].present?
      @characters = @characters.where("characters.name ILIKE ?", "%#{params[:search]}%") if params[:search].present?
      @factions = @characters.map(&:faction).uniq.compact.sort_by(&:name)
      @characters = paginate(@characters, per_page: (params[:per_page] || 15), page: (params[:page] || 1))
      @archetypes = @characters.select("action_values->>'Archetype'").map { |c| c.action_values["Archetype"] }.compact.sort

      {
        characters: ActiveModelSerializers::SerializableResource.new(@characters, each_serializer: CharacterIndexSerializer).serializable_hash,
        factions: ActiveModelSerializers::SerializableResource.new(@factions, each_serializer: FactionSerializer).serializable_hash,
        archetypes: @archetypes,
        meta: pagination_meta(@characters)
      }.to_json
    end

    render json: JSON.parse(cached_result)
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
