class Api::V2::OnboardingController < ApplicationController
  before_action :authenticate_user!
  
  def dismiss_congratulations
    begin
      current_user.ensure_onboarding_progress!
      current_user.onboarding_progress.update!(congratulations_dismissed_at: Time.current)
      render json: { 
        success: true,
        onboarding_progress: OnboardingProgressSerializer.new(current_user.onboarding_progress).as_json
      }
    rescue ActiveRecord::RecordInvalid => e
      render json: { 
        success: false,
        errors: e.record.errors
      }, status: :unprocessable_content
    rescue StandardError => e
      Rails.logger.error "Failed to dismiss congratulations for user #{current_user.id}: #{e.message}"
      render json: { 
        success: false,
        errors: { base: ["Failed to dismiss congratulations. Please try again."] }
      }, status: :internal_server_error
    end
  end

  def update
    begin
      current_user.ensure_onboarding_progress!
      
      if current_user.onboarding_progress.update(onboarding_progress_params)
        render json: { 
          success: true,
          onboarding_progress: OnboardingProgressSerializer.new(current_user.onboarding_progress).as_json
        }
      else
        render json: { 
          success: false,
          errors: current_user.onboarding_progress.errors
        }, status: :unprocessable_content
      end
    rescue ActiveRecord::RecordInvalid => e
      render json: { 
        success: false,
        errors: e.record.errors
      }, status: :unprocessable_content
    rescue StandardError => e
      Rails.logger.error "Failed to update onboarding progress for user #{current_user.id}: #{e.message}"
      render json: { 
        success: false,
        errors: { base: ["Failed to update onboarding progress. Please try again."] }
      }, status: :internal_server_error
    end
  end

  private

  def onboarding_progress_params
    params.require(:onboarding_progress).permit(
      :first_campaign_created_at,
      :first_campaign_activated_at,
      :first_character_created_at,
      :first_fight_created_at,
      :first_faction_created_at,
      :first_party_created_at,
      :first_site_created_at,
      :congratulations_dismissed_at
    )
  end
end