require "rails_helper"

RSpec.describe Character, type: :model do
  let!(:user) { User.create!(email: "email@example.com", confirmed_at: Time.now) }
  let!(:action_movie) { user.campaigns.create!(name: "Action Movie") }
  let(:brick) { user.characters.create!(name: "Brick Manly", campaign: action_movie) }
  let(:fight) { action_movie.fights.create!(name: "Big Brawl") }
  let(:dragons) { action_movie.factions.create!(name: "Dragons") }

  describe "associations" do
    it "belongs to a user" do
      expect(brick.user).to eq(user)
    end

    it "belongs to a campaign" do
      expect(brick.campaign).to eq(action_movie)
    end

    it "has many action values" do
      expect(brick.action_values).to be_a(Hash)
    end

    it "has many fights" do
      fight.characters << brick
      expect(brick.fights).to include(fight)
    end

    it "has many character_effects" do
      shot = fight.shots.create!(character: brick, shot: 10)
      effect = shot.character_effects.create!(name: "Injured", character: brick)
      expect(brick.character_effects).to include(effect)
    end

    it "has many schticks" do
      schtick = brick.schticks.create!(name: "Schtick 1", campaign: action_movie)
      expect(brick.schticks).to include(schtick)
    end

    it "has many advancements" do
      advancement = brick.advancements.create!(description: "Advancement 1")
      expect(brick.advancements).to include(advancement)
    end

    it "has many weapons" do
      weapon = brick.weapons.create!(name: "Gun", campaign: action_movie, damage: "7")
      expect(brick.weapons).to include(weapon)
    end

    it "has many parties" do
      party = action_movie.parties.create!(name: "The Dragons")
      party.characters << brick
      expect(brick.parties).to include(party)
    end

    it "has many sites" do
      site = action_movie.sites.create!(name: "The Warehouse")
      site.characters << brick
      expect(brick.sites).to include(site)
    end
  end

  describe "validations" do
    it "requires a name" do
      brick.name = nil
      expect(brick).to_not be_valid
    end

    it "requires a unique name" do
      brick.save!
      expect(Character.new(name: "Brick Manly", campaign: action_movie)).to_not be_valid
    end

    it "may have a duplicate name in a different campaign" do
      brick.save!
      expect(Character.new(name: "Brick Manly", campaign: user.campaigns.create!(name: "Other Campaign"))).to be_valid
    end

    it "requires a campaign" do
      brick.campaign = nil
      expect(brick).to_not be_valid
    end

    it "doesn't require a user" do
      brick.user = nil
      expect(brick).to be_valid
    end

    it "sets default action values" do
      expect(brick.action_values).to eq(Character::DEFAULT_ACTION_VALUES)
    end

    it "sets default description" do
      expect(brick.description).to eq(Character::DEFAULT_DESCRIPTION)
    end

    it "sets default skills" do
      expect(brick.skills).to eq(Character::DEFAULT_SKILLS)
    end

    it "sets integer values if you try to save strings" do
      brick.action_values["Guns"] = "14"
      brick.save!
      expect(brick.action_values["Guns"]).to eq(14)
      expect(brick.action_values["MainAttack"]).to eq("Guns")
    end

    it "requires schticks to have a name" do
      brick.schticks.create!(name: "Schtick 1", campaign: action_movie)
      expect(brick).to be_valid
      brick.schticks.create(name: nil, campaign: action_movie)
      expect(brick).to_not be_valid
      expect(brick.errors[:schticks]).to include("is invalid")
    end
  end

  describe "instance methods" do
    describe "#sort_order" do
      it "returns 0 for a Character, 0 for an Uber-Boss, inverse of speed, and name" do
        brick.action_values["Speed"] = 6
        brick.action_values["Type"] = "Uber-Boss"
        expect(brick.sort_order).to eq([0, 0, -6, "Brick Manly"])
      end

      it "returns 0 for a Character, 1 for a PC, inverse of speed, and name" do
        brick.action_values["Speed"] = 6
        expect(brick.sort_order).to eq([0, 1, -6, "Brick Manly"])
      end

      it "returns 0 for a Character, 2 for a Boss, inverse of speed, and name" do
        brick.action_values["Speed"] = 6
        brick.action_values["Type"] = "Boss"
        expect(brick.sort_order).to eq([0, 2, -6, "Brick Manly"])
      end

      it "returns 0 for a Character, 3 for a Featured Foe, inverse of speed, and name" do
        brick.action_values["Speed"] = 6
        brick.action_values["Type"] = "Featured Foe"
        expect(brick.sort_order).to eq([0, 3, -6, "Brick Manly"])
      end

      it "returns 0 for a Character, 4 for an Ally, inverse of speed, and name" do
        brick.action_values["Speed"] = 6
        brick.action_values["Type"] = "Ally"
        expect(brick.sort_order).to eq([0, 4, -6, "Brick Manly"])
      end

      it "returns 0 for a Character, 5 for a Mook, inverse of speed, and name" do
        brick.action_values["Speed"] = 6
        brick.action_values["Type"] = "Mook"
        expect(brick.sort_order).to eq([0, 5, -6, "Brick Manly"])
      end
    end

    describe "#good_guy?" do
      it "returns true if the character is a PC or Ally" do
        brick.action_values["Type"] = "PC"
        expect(brick.good_guy?).to be true
        brick.action_values["Type"] = "Ally"
        expect(brick.good_guy?).to be true
      end

      it "returns false if the character is not a PC or Ally" do
        brick.action_values["Type"] = "Boss"
        expect(brick.good_guy?).to be false
        brick.action_values["Type"] = "Featured Foe"
        expect(brick.good_guy?).to be false
        brick.action_values["Type"] = "Mook"
        expect(brick.good_guy?).to be false
      end
    end

    describe "#bad_guy?" do
      it "returns true if the character is a Boss, Featured Foe, or Mook" do
        brick.action_values["Type"] = "Boss"
        expect(brick.bad_guy?).to be true
        brick.action_values["Type"] = "Featured Foe"
        expect(brick.bad_guy?).to be true
        brick.action_values["Type"] = "Mook"
        expect(brick.bad_guy?).to be true
      end

      it "returns false if the character is not a Boss, Featured Foe, or Mook" do
        brick.action_values["Type"] = "PC"
        expect(brick.bad_guy?).to be false
        brick.action_values["Type"] = "Ally"
        expect(brick.bad_guy?).to be false
      end
    end

    describe "#effects_for_fight" do
      it "returns an empty array if the character has no effects" do
        shot = fight.shots.create!(character: brick, shot: 10)
        expect(brick.effects_for_fight(fight)).to eq([])
      end

      it "returns an array of effects that are active in the fight" do
        shot = fight.shots.create!(character: brick, shot: 10)
        shot.character_effects.create!(name: "Effect 1")
        shot.character_effects.create!(name: "Effect 3")
        expect(brick.effects_for_fight(fight).map(&:name)).to eq(["Effect 1", "Effect 3"])
      end
    end

    describe "#main_attack" do
      it "returns the character's main attack" do
        brick.action_values["MainAttack"] = "Martial Arts"
        expect(brick.main_attack).to eq("Martial Arts")
      end

      it "returns Guns if the character has default main attack" do
        expect(brick.main_attack).to eq("Guns")
      end
    end

    describe "#secondary_attack" do
      it "returns the character's secondary attack" do
        brick.action_values["SecondaryAttack"] = "Sorcery"
        expect(brick.secondary_attack).to eq("Sorcery")
      end

      it "returns Martial Arts if the character has default secondary attack" do
        brick.action_values["SecondaryAttack"] = "Martial Arts"
        expect(brick.secondary_attack).to eq("Martial Arts")
      end
    end

    describe "#fortune_type" do
      it "returns the character's fortune type" do
        brick.action_values["FortuneType"] = "Magic"
        expect(brick.fortune_type).to eq("Magic")
      end

      it "returns Fortune if the character has default fortune type" do
        expect(brick.fortune_type).to eq("Fortune")
      end
    end
  end
end
