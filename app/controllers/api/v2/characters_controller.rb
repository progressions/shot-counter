class Api::V2::CharactersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign
  before_action :set_scoped_characters
  before_action :set_character, only: [:update, :destroy, :show, :remove_image, :sync, :pdf]

  def index
    sort = params[:sort] || "created_at"
    order = params[:order] || "DESC"

    if sort == "type"
      sort = Arel.sql("COALESCE(action_values->>'Type', '') #{order}")
    elsif sort == "name"
      sort = Arel.sql("LOWER(characters.name) #{order}")
    elsif sort == "created_at"
      sort = Arel.sql("characters.created_at #{order}")
    else
      sort = Arel.sql("#{sort} #{order}")
    end

    @characters = @scoped_characters
      .includes(:user)
      .includes(:faction)
      .includes(:attunements)
      .includes(:sites)
      .includes(:carries)
      .includes(:weapons)
      .includes(:juncture)
      .includes(:schticks)
      .includes(:advancements)
      .order(sort)

    if params[:user_id]
      @characters = @characters.where(user_id: params[:user_id])
    end

    @factions = Faction.where(id: @characters.pluck(:faction_id).uniq).order(:name)

    @characters = paginate(@characters, per_page: (params[:per_page] || 15), page: (params[:page] || 1))

    render json: {
      characters: @characters,
      factions: @factions,
      archetypes: @archetypes,
      meta: pagination_meta(@characters)
    }
  end

  def create
    @character = current_campaign.characters.create!(character_params)
    @character.user = current_user
    @character.campaign = current_campaign

    if @character.save
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
      SyncCharacterToNotionJob.perform_later(@character.id)
      render json: @character
    else
      render @character.errors, status: 400
    end
  end

  def destroy
    @character.carries.destroy_all
    @character.destroy!
    render :ok
  end

  def import
    if params[:pdf_file].present?
      # Initialize PDFtk with the path to the pdftk binary
      pdftk = PdfForms.new('/usr/local/bin/pdftk') # Adjust path as needed

      # Save uploaded PDF temporarily
      uploaded_file = params[:pdf_file]

      @character = PdfService.pdf_to_character(uploaded_file, current_campaign, { user: current_user })

      if @character.save
        render json: @character, status: :created
      else
        Rails.logger.error("Character import failed: #{@character.errors.full_messages.join(', ')}")
        render json: @character.errors, status: :unprocessable_entity
      end
    else
      @character = Character.new
      render json: { error: 'No PDF file provided' }, status: :bad_request
    end
  end

  def sync
    NotionService.update_character_from_notion(@character)

    render json: @character.reload
  end

  def remove_image
    @character.image.purge

    if @character.save
      render json: @character
    else
      render @character.errors, status: 400
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
