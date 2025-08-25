require 'rails_helper'

RSpec.describe Campaign, type: :model do
  let!(:gamemaster) do
    User.create!(
      email: 'gamemaster@example.com',
      first_name: 'Game',
      last_name: 'Master',
      password: 'TestPass123!',
      gamemaster: true
    )
  end

  describe 'campaign seeding' do
    context 'when creating a regular campaign' do
      it 'does not automatically seed the campaign' do
        campaign = Campaign.create!(name: 'Test Campaign', user: gamemaster)
        expect(campaign.seeded_at).to be_nil
      end

      it 'starts with no characters' do
        campaign = Campaign.create!(name: 'Test Campaign', user: gamemaster)
        expect(campaign.characters.count).to eq(0)
      end
    end

    context 'when creating a master template campaign' do
      it 'also does not automatically seed' do
        campaign = Campaign.create!(
          name: 'Master Template',
          is_master_template: true,
          user: gamemaster
        )
        expect(campaign.seeded_at).to be_nil
      end
    end

    context 'manual seeding' do
      it 'can be seeded manually via the job' do
        campaign = Campaign.create!(name: 'Test Campaign', user: gamemaster)
        
        # Create a master template for seeding
        master = Campaign.create!(
          name: 'Master Template',
          is_master_template: true,
          user: gamemaster
        )
        Character.create!(name: 'Template Character', is_template: true, campaign: master)
        
        # Manually trigger seeding
        CampaignSeederJob.perform_now(campaign.id)
        
        campaign.reload
        expect(campaign.seeded_at).to be_present
        expect(campaign.characters.count).to be > 0
      end
    end
  end
end