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
      response = FightPoster.shots(fight)
      puts response
      expect(response).to eq(expected)
    end
  end

  context "with characters" do
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
 Guns 15  /  Defense 14  /  Toughness 7  /  Speed 7

      TEXT
    end

    it "shows fight" do
      response = FightPoster.shots(fight)
      puts response
      expect(response).to eq(expected)
    end
  end
end
