require 'rails_helper'

RSpec.describe FightPoster do
  let(:user) { User.create!(email: "email@example.com") }
  let(:action_movie) { user.campaigns.create!(title: "Action Movie") }
  let(:fight) { Fight.create!(name: "Museum Battle", campaign_id: action_movie.id) }

  context "with no shots or characters" do
    let(:expected) do
      <<-TEXT
# Museum Battle
### Sequence 0
      TEXT
    end

    it "shows fight" do
      response = FightPoster.show(fight)
      puts response
      expect(response).to eq(expected)
    end
  end

  context "with one character" do
    before(:each) do
      brick = Character.create!(name: "Brick Manly", action_values: {"Type" => "PC", "Guns" => 15, "Defense" => 14, "Toughness" => 7, "Speed" => 7, "Fortune" => 7}, campaign_id: action_movie.id)
      fight.fight_characters.create!(character: brick, shot: 12)
    end

    let(:expected) do
      <<-TEXT
# Museum Battle
### Sequence 0
## Shot 12
- **Brick Manly**
 0 Wounds
 Guns 15 / Defense 14 / Toughness 7 / Speed 7
      TEXT
    end

    it "shows fight" do
      response = FightPoster.show(fight)
      puts
      puts response
      puts
      expect(response).to eq(expected)
    end
  end

  context "with two characters" do
    before(:each) do
      brick = Character.create!(name: "Brick Manly", action_values: {"Type" => "PC", "Guns" => 15, "Defense" => 14, "Toughness" => 7, "Speed" => 7, "Fortune" => 7}, campaign_id: action_movie.id)
      fight.fight_characters.create!(character: brick, shot: 12)
      serena = Character.create!(name: "Serena", action_values: {"Type" => "PC", "MainAttack" => "Sorcery", "Sorcery" => 14, "Defense" => 13, "Toughness" => 7, "Speed" => 6, "Fortune" => 7}, campaign_id: action_movie.id)
      fight.fight_characters.create!(character: serena, shot: 14)
    end

    let(:expected) do
      <<-TEXT
# Museum Battle
### Sequence 0
## Shot 14
- **Serena**
 0 Wounds
 Sorcery 14 / Defense 13 / Toughness 7 / Speed 6
## Shot 12
- **Brick Manly**
 0 Wounds
 Guns 15 / Defense 14 / Toughness 7 / Speed 7
      TEXT
    end

    it "shows fight" do
      response = FightPoster.show(fight)
      puts
      puts response
      puts
      expect(response).to eq(expected)
    end
  end
end
