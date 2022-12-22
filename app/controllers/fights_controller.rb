class FightsController < ApplicationController
  def index
    render json: { name: "Hello" }
  end
end
