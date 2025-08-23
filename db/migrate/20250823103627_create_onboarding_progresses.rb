class CreateOnboardingProgresses < ActiveRecord::Migration[8.0]
  def change
    create_table :onboarding_progresses, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.timestamp :first_campaign_created_at
      t.timestamp :first_character_created_at
      t.timestamp :first_fight_created_at
      t.timestamp :first_faction_created_at
      t.timestamp :first_party_created_at
      t.timestamp :first_site_created_at
      t.timestamp :congratulations_dismissed_at

      t.timestamps
    end
  end
end
