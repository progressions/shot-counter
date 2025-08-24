class OnboardingProgress < ApplicationRecord
  belongs_to :user

  MILESTONE_SEQUENCE = [
    { key: 'campaign', timestamp_field: :first_campaign_created_at },
    { key: 'activate-campaign', timestamp_field: :first_campaign_activated_at },
    { key: 'character', timestamp_field: :first_character_created_at },
    { key: 'faction', timestamp_field: :first_faction_created_at },
    { key: 'party', timestamp_field: :first_party_created_at },
    { key: 'site', timestamp_field: :first_site_created_at },
    { key: 'fight', timestamp_field: :first_fight_created_at }
  ].freeze

  def all_milestones_complete?
    milestone_timestamps.all?(&:present?)
  end

  def onboarding_complete?
    all_milestones_complete? && congratulations_dismissed_at.present?
  end

  def ready_for_congratulations?
    all_milestones_complete? && congratulations_dismissed_at.nil?
  end

  def next_milestone
    MILESTONE_SEQUENCE.find { |m| send(m[:timestamp_field]).nil? }
  end

  private

  def milestone_timestamps
    [
      first_campaign_created_at,
      first_campaign_activated_at,
      first_character_created_at,
      first_fight_created_at,
      first_faction_created_at,
      first_party_created_at,
      first_site_created_at
    ]
  end
end