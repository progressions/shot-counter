class Api::V1::FightEventsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign
  before_action :set_fight

  def index
    render json: @fight.fight_events.order(created_at: :asc)
  end

  def create
    event = @fight.fight_events.build(event_params)
    if event.save
      @fight.send(:enqueue_discord_notification)
      @fight.send(:broadcast_update)

      render json: event, status: :created
    else
      render json: event.errors, status: :unprocessable_content
    end
  end

  private

  def event_params
    params.require(:fight_event).permit(:event_type, :description, details: {})
  end

  def set_fight
    @fight = current_campaign
      .fights
      .find(params[:fight_id])
  end
end
