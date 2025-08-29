require 'rails_helper'

RSpec.describe Campaign, type: :model do
  let!(:user) { User.create!(email: "email@example.com", first_name: "John", last_name: "Doe", confirmed_at: Time.now) }
  let!(:action_movie) { user.campaigns.create!(name: "Action Movie") }
  let(:brick) { Character.create!(name: "Brick Manly", campaign: action_movie) }

  describe "validations" do
    it "requires a name" do
      expect(Campaign.create(name: nil)).to be_invalid
    end

    describe "master template validation" do
      it "allows one master template to exist" do
        master_template = Campaign.create!(
          name: "Master Template", 
          user: user,
          is_master_template: true
        )
        
        expect(master_template).to be_valid
        expect(master_template.is_master_template?).to be true
      end

      it "prevents multiple master templates from being created" do
        # Create first master template
        Campaign.create!(
          name: "First Master", 
          user: user,
          is_master_template: true
        )

        # Try to create second master template
        second_master = Campaign.build(
          name: "Second Master",
          user: user,
          is_master_template: true
        )

        expect(second_master).to be_invalid
        expect(second_master.errors[:is_master_template]).to include("can only be true for one campaign at a time")
      end

      it "allows updating a master template without validation errors" do
        master_template = Campaign.create!(
          name: "Master Template", 
          user: user,
          is_master_template: true
        )

        # Update the master template
        master_template.name = "Updated Master Template"
        expect(master_template).to be_valid
        expect(master_template.save).to be true
      end

      it "allows changing a master template to non-master" do
        master_template = Campaign.create!(
          name: "Master Template", 
          user: user,
          is_master_template: true
        )

        # Change from master to non-master
        master_template.is_master_template = false
        expect(master_template).to be_valid
        expect(master_template.save).to be true
      end

      it "allows creating a new master template after removing the old one" do
        # Create first master template
        first_master = Campaign.create!(
          name: "First Master", 
          user: user,
          is_master_template: true
        )

        # Change it to non-master
        first_master.update!(is_master_template: false)

        # Now create a new master template
        second_master = Campaign.build(
          name: "Second Master",
          user: user,
          is_master_template: true
        )

        expect(second_master).to be_valid
        expect(second_master.save).to be true
      end

      it "allows non-master templates to be created even when master template exists" do
        # Create master template
        Campaign.create!(
          name: "Master Template", 
          user: user,
          is_master_template: true
        )

        # Create regular campaign
        regular_campaign = Campaign.build(
          name: "Regular Campaign",
          user: user,
          is_master_template: false
        )

        expect(regular_campaign).to be_valid
        expect(regular_campaign.save).to be true
      end
    end
  end

  describe "associations" do
    it "has many characters" do
      expect(action_movie.characters).to eq([brick])
    end

    it "has many weapons" do
      weapon = action_movie.weapons.create!(name: "Sword", damage: "10")
      expect(action_movie.weapons).to eq([weapon])
    end

    it "has many players" do
      action_movie.users << user
      expect(action_movie.users).to eq([user])
    end

    it "has many campaign_memberships" do
      action_movie.users << user
      expect(action_movie.campaign_memberships).to eq([user.campaign_memberships.first])
    end

    it "has many fights" do
      fight = Fight.create!(name: "Fight", campaign: action_movie)
      expect(action_movie.fights).to eq([fight])
    end

    it "has many vehicles" do
      vehicle = Vehicle.create!(name: "Car", campaign: action_movie)
      expect(action_movie.vehicles).to eq([vehicle])
    end

    it "has many invitations" do
      invitation = Invitation.create!(email: "invite@example.com", campaign: action_movie, user: user)
      expect(action_movie.invitations).to eq([invitation])
    end

    it "has many schticks" do
      schtick = Schtick.create!(name: "Schtick", campaign: action_movie, category: "Guns")
      expect(action_movie.schticks).to eq([schtick])
    end

    it "has many parties" do
      party = Party.create!(name: "Party", campaign: action_movie)
      expect(action_movie.parties).to eq([party])
    end

    it "has many sites" do
      site = Site.create!(name: "Site", campaign: action_movie)
      expect(action_movie.sites).to eq([site])
    end

    it "has many factions" do
      faction = Faction.create!(name: "Faction", campaign: action_movie)
      expect(action_movie.factions).to eq([faction])
    end
  end
end
