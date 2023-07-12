require 'rails_helper'

RSpec.describe CharacterPoster do
  let(:user) { User.create!(email: "email@example.com") }
  let(:action_movie) { user.campaigns.create!(name: "Action Movie") }
  let(:brick) { Character.create!(name: "Brick Manly", action_values: {"Type" => "PC", "Guns" => 15, "Defense" => 14, "Toughness" => 7, "Speed" => 7, "Fortune" => 7, "Max Fortune" => 7}, campaign_id: action_movie.id) }

  context "when the character has no skills" do
    let(:expected) do
      <<-TEXT
# Brick Manly

## Action Values
- Guns 15
- Defense 14
- Fortune 7/7
- Toughness 7
- Speed 7
TEXT
    end

    it "shows character" do
      response = CharacterPoster.show(brick)
      puts
      puts response
      puts
      expect(response).to eq(expected)
    end
  end

  context "with an archetype and skills" do
    let(:expected) do
      <<-TEXT
# Brick Manly
## Everyday Hero

## Action Values
- Guns 15
- Defense 14
- Fortune 7/7
- Toughness 7
- Speed 7
## Skills
- Info: Classic Rock 15
TEXT
    end

    it "shows character" do
      brick.action_values["Archetype"] = "Everyday Hero"
      brick.skills["Info: Classic Rock"] = 15
      response = CharacterPoster.show(brick)
      puts
      puts response
      puts
      expect(response).to eq(expected)
    end
  end

  context "with schticks and weapons" do
    let(:expected) do
      <<-TEXT
# Brick Manly
## Everyday Hero

## Action Values
- Guns 15
- Defense 14
- Fortune 7/7
- Toughness 7
- Speed 7
## Skills
- Info: Classic Rock 15
## Weapons
- Guitar (10/4/2)
## Schticks
- Rocker
TEXT
    end

    it "shows character" do
      brick.action_values["Archetype"] = "Everyday Hero"
      brick.skills["Info: Classic Rock"] = 15
      brick.schticks << Schtick.new(name: "Rocker", campaign_id: action_movie.id)
      brick.weapons << Weapon.new(name: "Guitar", campaign_id: action_movie.id, damage: 10, concealment: 4, reload_value: 2)
      response = CharacterPoster.show(brick)
      puts
      puts response
      puts
      expect(response).to eq(expected)
    end
  end
end
