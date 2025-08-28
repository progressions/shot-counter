class HealthController < ApplicationController
  skip_before_action :set_current_campaign
  
  def show
    # Basic health check - verify app and database are responding
    health_status = {
      status: 'ok',
      timestamp: Time.current,
      database: check_database_connection
    }
    
    render json: health_status, status: :ok
  rescue => e
    render json: { status: 'error', message: e.message }, status: :service_unavailable
  end
  
  private
  
  def check_database_connection
    ActiveRecord::Base.connection.active? ? 'ok' : 'error'
  rescue => e
    'error'
  end
end