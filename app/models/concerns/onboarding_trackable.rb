module OnboardingTrackable
  extend ActiveSupport::Concern

  included do
    after_create :track_onboarding_milestone
  end

  private

  def track_onboarding_milestone
    Rails.logger.info "🎯 OnboardingTrackable: Tracking milestone for #{self.class.name} (ID: #{id})"
    
    # Skip tracking for template characters
    if self.class.name == "Character" && respond_to?(:is_template) && is_template
      Rails.logger.info "⏭️ Skipping milestone tracking for template character: #{name}"
      return
    end
    
    # Get the user - either directly or through campaign
    target_user = if respond_to?(:user) && user.present?
      Rails.logger.info "📍 Found user directly: #{user.email}"
      user
    elsif respond_to?(:campaign) && campaign.present? && campaign.user.present?
      Rails.logger.info "📍 Found user through campaign: #{campaign.user.email}"
      campaign.user
    else
      Rails.logger.warn "❌ No user found for #{self.class.name} (ID: #{id})"
      nil
    end
    
    return unless target_user
    
    milestone_type = self.class.name.downcase
    timestamp_field = "first_#{milestone_type}_created_at"
    
    Rails.logger.info "🏆 Processing milestone: #{milestone_type} -> #{timestamp_field}"
    
    # Ensure user has onboarding progress record
    target_user.ensure_onboarding_progress!
    Rails.logger.info "✅ Ensured onboarding progress record exists"
    
    # Only set if not already set (idempotent)
    current_value = target_user.onboarding_progress.send(timestamp_field)
    Rails.logger.info "📊 Current #{timestamp_field}: #{current_value.inspect}"
    
    if current_value.nil?
      target_user.onboarding_progress.update!(timestamp_field => Time.current)
      Rails.logger.info "🎉 Set #{timestamp_field} to #{Time.current} for user #{target_user.email}"
    else
      Rails.logger.info "⚠️ #{timestamp_field} already set to #{current_value}, skipping"
    end
  rescue => e
    Rails.logger.warn "❌ Failed to track onboarding milestone: #{e.message}"
    Rails.logger.warn "❌ Backtrace: #{e.backtrace.join("\n")}"
  end
end