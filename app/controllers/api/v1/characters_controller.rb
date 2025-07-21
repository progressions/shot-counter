class Api::V1::CharactersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign
  before_action :set_scoped_characters
  before_action :set_character, only: [:update, :destroy, :show, :remove_image, :sync, :pdf]

  def index
    @characters = @scoped_characters.includes(:user).order(:name).all
    render json: @characters
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
