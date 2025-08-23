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

  describe 'campaign seeding hook' do
    context 'when creating a regular campaign' do
      it 'enqueues a seeding job' do
        expect {
          Campaign.create!(name: 'Test Campaign', user: gamemaster)
        }.to have_enqueued_job(CampaignSeederJob)
      end

      it 'passes the campaign id to the job' do
        campaign = Campaign.create!(name: 'Test Campaign', user: gamemaster)
        expect(CampaignSeederJob).to have_been_enqueued.with(campaign.id)
      end
    end

    context 'when creating a master template campaign' do
      it 'does not enqueue a seeding job' do
        expect {
          Campaign.create!(
            name: 'Master Template',
            is_master_template: true,
            user: gamemaster
          )
        }.not_to have_enqueued_job(CampaignSeederJob)
      end
    end
  end
end