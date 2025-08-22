require "rails_helper"

RSpec.describe CharacterOwnershipService do
  before(:each) do
    @gamemaster = User.create!(email: "gamemaster@example.com", confirmed_at: Time.now, gamemaster: true)
    @player = User.create!(email: "player@example.com", confirmed_at: Time.now)
    @new_owner = User.create!(email: "newowner@example.com", confirmed_at: Time.now)
    @admin = User.create!(email: "admin@example.com", confirmed_at: Time.now, admin: true)
    @non_member = User.create!(email: "nonmember@example.com", confirmed_at: Time.now)
    
    @campaign = @gamemaster.campaigns.create!(name: "Test Campaign")
    @campaign.users << @player
    @campaign.users << @new_owner
    
    @character = @campaign.characters.create!(
      name: "Test Character",
      user: @player,
      action_values: { "Type" => "PC" }
    )
  end

  describe ".transfer" do
    context "as gamemaster" do
      it "successfully transfers ownership to another campaign member" do
        result = CharacterOwnershipService.transfer(
          character: @character,
          new_owner: @new_owner,
          actor: @gamemaster
        )
        
        expect(result).to be true
        expect(@character.reload.user).to eq(@new_owner)
      end

      it "fails when new owner is not a campaign member" do
        service = CharacterOwnershipService.new(
          character: @character,
          new_owner: @non_member,
          actor: @gamemaster
        )
        
        result = service.transfer
        
        expect(result).to be false
        expect(service.errors).to include("New owner must be a member of the campaign")
        expect(@character.reload.user).to eq(@player)
      end

      it "fails when new owner is nil" do
        service = CharacterOwnershipService.new(
          character: @character,
          new_owner: nil,
          actor: @gamemaster
        )
        
        result = service.transfer
        
        expect(result).to be false
        expect(service.errors).to include("New owner must be specified")
        expect(@character.reload.user).to eq(@player)
      end

      it "fails when transferring to the same owner" do
        service = CharacterOwnershipService.new(
          character: @character,
          new_owner: @player,
          actor: @gamemaster
        )
        
        result = service.transfer
        
        expect(result).to be false
        expect(service.errors).to include("Character already belongs to this user")
      end
    end

    context "as admin" do
      it "successfully transfers ownership" do
        result = CharacterOwnershipService.transfer(
          character: @character,
          new_owner: @new_owner,
          actor: @admin
        )
        
        expect(result).to be true
        expect(@character.reload.user).to eq(@new_owner)
      end
    end

    context "as regular player" do
      it "fails due to lack of authorization" do
        service = CharacterOwnershipService.new(
          character: @character,
          new_owner: @new_owner,
          actor: @player
        )
        
        result = service.transfer
        
        expect(result).to be false
        expect(service.errors).to include("You are not authorized to transfer ownership of this character")
        expect(@character.reload.user).to eq(@player)
      end
    end

    context "with gamemaster from different campaign" do
      it "fails due to lack of authorization" do
        other_gm = User.create!(email: "othergm@example.com", confirmed_at: Time.now, gamemaster: true)
        other_campaign = other_gm.campaigns.create!(name: "Other Campaign")
        
        service = CharacterOwnershipService.new(
          character: @character,
          new_owner: @new_owner,
          actor: other_gm
        )
        
        result = service.transfer
        
        expect(result).to be false
        expect(service.errors).to include("You are not authorized to transfer ownership of this character")
        expect(@character.reload.user).to eq(@player)
      end
    end
  end

  describe "logging" do
    it "logs ownership changes" do
      allow(Rails.logger).to receive(:info)
      expect(Rails.logger).to receive(:info).with(/Character ownership transferred/)
      
      CharacterOwnershipService.transfer(
        character: @character,
        new_owner: @new_owner,
        actor: @gamemaster
      )
    end
  end
end