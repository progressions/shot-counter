class Api::V1::AllCharactersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_scoped_characters

  def index
    @characters = @scoped_characters.all
    render json: @characters
  end

  private

  def set_scoped_characters
    if current_user.gamemaster?
      @scoped_characters = Character
    else
      @scoped_characters = current_user.characters
    end
  end

end
