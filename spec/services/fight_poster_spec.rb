require 'rails_helper'

RSpec.describe FightPoster do
  let(:user) { User.create!(email: "email@example.com") }
  let(:action_movie) { user.campaigns.create!(title: "Action Movie") }
  let(:fight) { Fight.create!(name: "Museum Battle", campaign_id: action_movie.id, sequence: 1) }
  let(:other_fight) { Fight.create!(name: "Other Fight", campaign_id: action_movie.id, sequence: 1) }

  context "with no shots or characters" do
    let(:expected) do
      <<-TEXT
# Museum Battle
## Sequence 1
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
      brick = Character.create!(name: "Brick Manly", action_values: {"Type" => "PC", "Guns" => 15, "Defense" => 14, "Toughness" => 7, "Speed" => 7, "Fortune" => 7, "Max Fortune" => 7}, campaign_id: action_movie.id)
      fight.fight_characters.create!(character: brick, shot: 12)
    end

    let(:expected) do
      <<-TEXT
# Museum Battle
## Sequence 1
## Shot 12
- **Brick Manly**
 Guns 15 Defense 14 Fortune 7/7 Toughness 7 Speed 7
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
      brick = Character.create!(name: "Brick Manly", action_values: {"Type" => "PC", "Guns" => 15, "Defense" => 14, "Toughness" => 7, "Speed" => 7, "Fortune" => 7, "Max Fortune" => 7}, campaign_id: action_movie.id)
      fight.fight_characters.create!(character: brick, shot: 12)
      serena = Character.create!(name: "Serena", action_values: {"Type" => "PC", "MainAttack" => "Sorcery", "FortuneType" => "Magic", "Sorcery" => 14, "Defense" => 13, "Toughness" => 7, "Speed" => 6, "Fortune" => 5, "Max Fortune" => 7}, campaign_id: action_movie.id, impairments: 1)
      fight.fight_characters.create!(character: serena, shot: 14)
    end

    let(:expected) do
      <<-TEXT
# Museum Battle
## Sequence 1
## Shot 14
- **Serena**
 (1 Impairment)
 Sorcery 13* Defense 12* Magic 4/6* Toughness 6* Speed 5*
## Shot 12
- **Brick Manly**
 Guns 15 Defense 14 Fortune 7/7 Toughness 7 Speed 7
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

  context "with multiple characters of different types" do
    before(:each) do
      # Uber-Boss
      thunder_king = Character.create!(name: "Thunder King", action_values: {"Type" => "Uber-Boss", "Guns" => 18, "Defense" => 17, "Toughness" => 9, "Speed" => 8}, campaign_id: action_movie.id)
      # Boss
      shing = Character.create!(name: "Ugly Shing", action_values: {"Type" => "Boss", "Guns" => 15, "Defense" => 14, "Toughness" => 7, "Speed" => 7}, campaign_id: action_movie.id)
      # Featured Foe
      hitman = Character.create!(name: "Hitman", action_values: {"Type" => "Featured Foe", "Guns" => 15, "Defense" => 14, "Toughness" => 7, "Speed" => 7}, campaign_id: action_movie.id)
      # Ally
      jawbuster = Character.create!(name: "Jawbuster", action_values: {"Type" => "Ally", "Guns" => 15, "Defense" => 14, "Toughness" => 7, "Speed" => 7, "Wounds" => 12}, campaign_id: action_movie.id)
      # Mook
      mook = Character.create!(name: "Ninja", action_values: {"Type" => "Mook", "Guns" => 8, "Defense" => 13, "Toughness" => 7, "Speed" => 6}, campaign_id: action_movie.id)
      # PC
      brick = Character.create!(name: "Brick Manly", action_values: {"Type" => "PC", "Guns" => 15, "Defense" => 14, "Toughness" => 7, "Speed" => 7, "Fortune" => 7, "Max Fortune" => 7}, campaign_id: action_movie.id)
      # PC
      serena = Character.create!(name: "Serena", action_values: {"Type" => "PC", "MainAttack" => "Sorcery", "FortuneType" => "Magic", "Sorcery" => 14, "Defense" => 13, "Toughness" => 7, "Speed" => 6, "Fortune" => 5, "Max Fortune" => 7, "Wounds" => 39}, campaign_id: action_movie.id, impairments: 2)

      fight.fight_characters.create!(character: mook, shot: nil)
      fight.fight_characters.create!(character: jawbuster, shot: 10)
      fight.fight_characters.create!(character: hitman, shot: 9)
      fight.fight_characters.create!(character: shing, shot: 10)
      brick_in_fight = fight.fight_characters.create!(character: brick, shot: 12)
      serena_in_fight = fight.fight_characters.create!(character: serena, shot: 14)
      fight.fight_characters.create!(character: thunder_king, shot: 12)

      brick_in_other_fight = other_fight.fight_characters.create!(character: brick, shot: 12)

      brick_in_fight.character_effects.create!(:title=>"Bonus", :description=>"Got lucky", :severity=>"info", :action_value=>"MainAttack", :change=>"+1")
      brick_in_fight.character_effects.create!(:title=>"Blinded", :description=>"", :severity=>"error", :action_value=>"Defense", :change=>"-1")
      brick_in_other_fight.character_effects.create!(:title=>"Effect in Other Fight", :description=>"", :severity=>"error", :action_value=>"Defense", :change=>"-1")
      serena_in_fight.character_effects.create!(title: "Feeling weird")

      fight.effects.create!(title: "Shadow of the Sniper", description: "+1 Attack", severity: "success", start_sequence: 1, end_sequence: 2, start_shot: 14, end_shot: 14)
      fight.effects.create!(title: "Some effect", description: "", severity: "error", start_sequence: 1, end_sequence: 2, start_shot: 16, end_shot: 16)
      fight.effects.create!(title: "Some other effect", description: "", severity: "success", start_sequence: 1, end_sequence: 2, start_shot: 9, end_shot: 9)
    end

    let(:expected) do
      <<-TEXT
# Museum Battle
## Sequence 1
```diff
- Some effect (until sequence 2, shot 16)
+ Shadow of the Sniper: +1 Attack (until sequence 2, shot 14)
```
## Shot 14
- **Serena**
 39 Wounds (2 Impairments)
 Sorcery 12* Defense 11* Magic 3/5* Toughness 5* Speed 4*
  ```diff
 Feeling weird
 ```
## Shot 12
- **Thunder King**
- **Brick Manly**
 Guns 15 Defense 14 Fortune 7/7 Toughness 7 Speed 7
  ```diff
 Bonus: (Got lucky) Guns +1
 - Blinded: Defense -1
 ```
## Shot 10
- **Ugly Shing**
- **Jawbuster**
 12 Wounds
 Guns 15 Defense 14 Fortune 0/0 Toughness 7 Speed 7
## Shot 9
- **Hitman**
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
