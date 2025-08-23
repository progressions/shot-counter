module OnboardingTrackable
  extend ActiveSupport::Concern

  included do
    after_create :track_onboarding_milestone
  end

  private

  def track_onboarding_milestone
    # Get the user - either directly or through campaign
    target_user = if respond_to?(:user) && user.present?
      user
    elsif respond_to?(:campaign) && campaign.present? && campaign.user.present?
      campaign.user
    else
      nil
    end
    
    return unless target_user
    
    milestone_type = self.class.name.downcase
    timestamp_field = "first_#{milestone_type}_created_at"
    
    # Ensure user has onboarding progress record
    target_user.ensure_onboarding_progress!
    
    # Only set if not already set (idempotent)
    if target_user.onboarding_progress.send(timestamp_field).nil?
      target_user.onboarding_progress.update!(timestamp_field => Time.current)
    end
  rescue => e
    Rails.logger.warn "Failed to track onboarding milestone: #{e.message}"
  end
end