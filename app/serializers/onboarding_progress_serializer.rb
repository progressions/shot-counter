class OnboardingProgressSerializer < ActiveModel::Serializer
  attributes :id, :first_campaign_created_at, :first_character_created_at, 
             :first_fight_created_at, :first_faction_created_at, 
             :first_party_created_at, :first_site_created_at,
             :congratulations_dismissed_at, :all_milestones_complete,
             :onboarding_complete, :ready_for_congratulations, :next_milestone

  def all_milestones_complete
    object.all_milestones_complete?
  end

  def onboarding_complete
    object.onboarding_complete?
  end

  def ready_for_congratulations
    object.ready_for_congratulations?
  end

  def next_milestone
    object.next_milestone
  end
end