require 'rails_helper'

RSpec.describe WithImagekit, type: :model do
  let!(:user) { User.create!(email: "test@example.com", first_name: "Test", last_name: "User", confirmed_at: Time.now) }
  let!(:campaign) { user.campaigns.create!(name: "Test Campaign") }
  let(:image_file) { fixture_file_upload('spec/fixtures/files/image.jpg', 'image/jpeg') }

  describe '#clear_image_positions_on_image_change' do
    let!(:character) { user.characters.create!(name: "Test Character", campaign: campaign) }

    context 'when a new image is attached' do
      it 'clears all existing image positions' do
        # Create positions first
        character.image_positions.create!(
          context: 'desktop_entity',
          x_position: 100.0,
          y_position: 50.0
        )
        character.image_positions.create!(
          context: 'mobile_index', 
          x_position: -25.0,
          y_position: 75.0
        )
        
        expect(character.image_positions.count).to eq(2)
        
        character.image.attach(image_file)
        character.save!
        
        expect(character.image_positions.count).to eq(0)
      end

    end

    context 'when no image change occurs' do
      it 'does not clear positions when other attributes are updated' do
        character.image.attach(image_file)
        character.save!
        
        # Add positions after image attachment
        character.image_positions.create!(
          context: 'desktop_entity',
          x_position: 300.0,
          y_position: 250.0
        )
        
        expect(character.image_positions.count).to eq(1)
        
        character.update!(name: 'Updated Name')
        
        expect(character.image_positions.count).to eq(1)
        expect(character.image_positions.first.x_position).to eq(300.0)
      end
    end
  end

  describe 'works with different entity types' do
    let!(:vehicle) { campaign.vehicles.create!(name: "Test Vehicle") }
    let!(:site) { campaign.sites.create!(name: "Test Site") }

    it 'clears positions for vehicles' do
      vehicle.image_positions.create!(
        context: 'desktop_entity',
        x_position: 600.0,
        y_position: 550.0
      )
      
      expect(vehicle.image_positions.count).to eq(1)
      
      vehicle.image.attach(image_file)
      vehicle.save!
      
      expect(vehicle.image_positions.count).to eq(0)
    end

    it 'clears positions for sites' do
      site.image_positions.create!(
        context: 'mobile_index',
        x_position: 700.0,
        y_position: 650.0
      )
      
      expect(site.image_positions.count).to eq(1)
      
      site.image.attach(image_file)
      site.save!
      
      expect(site.image_positions.count).to eq(0)
    end
  end
end