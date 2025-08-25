class Api::V2::OnboardingController < ApplicationController
  before_action :authenticate_user!
  
  def dismiss_congratulations
    current_user.ensure_onboarding_progress!
    current_user.onboarding_progress.update!(congratulations_dismissed_at: Time.current)
    render json: { 
      success: true,
      onboarding_progress: OnboardingProgressSerializer.new(current_user.onboarding_progress).as_json
    }
  end

  def update
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
      }, status: :unprocessable_entity
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