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
end