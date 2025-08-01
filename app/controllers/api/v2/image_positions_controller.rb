class Api::V2::ImagePositionsController < ApplicationController
  before_action :set_positionable

  def show
    image_positions = @positionable.image_positions
    render json: image_positions, status: :ok
  end

  def create
    image_position = @positionable.image_positions.build(image_position_params.except(:positionable_type, :positionable_id))
    if image_position.save
      render json: image_position, status: :created
    else
      render json: image_position.errors, status: :unprocessable_entity
    end
  end

  def update
    image_position = @positionable.image_positions.find_or_initialize_by(context: image_position_params[:context])
    if image_position.update(image_position_params.except(:positionable_type, :positionable_id))
      render json: image_position, status: :ok
    else
      render json: image_position.errors, status: :unprocessable_entity
    end
  end

  private

  def set_positionable
    @positionable = params[:positionable_type].constantize.find(params[:positionable_id])
  end

  def image_position_params
    params.require(:image_position).permit(:context, :x_position, :y_position, style_overrides: {})
  end
end
