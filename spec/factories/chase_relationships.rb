FactoryBot.define do
  factory :chase_relationship do
    association :pursuer, factory: :vehicle
    association :evader, factory: :vehicle
    association :fight
    position { 'far' }
    active { true }

    trait :near do
      position { 'near' }
    end

    trait :far do
      position { 'far' }
    end

    trait :inactive do
      active { false }
    end

    before(:create) do |chase_relationship|
      # Ensure vehicles and fight belong to the same campaign
      if chase_relationship.pursuer && chase_relationship.evader && chase_relationship.fight
        campaign = chase_relationship.fight.campaign
        chase_relationship.pursuer.update(campaign: campaign)
        chase_relationship.evader.update(campaign: campaign)
      end
    end
  end
end