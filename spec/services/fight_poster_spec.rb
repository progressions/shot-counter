require 'rails_helper'

RSpec.describe FightPoster do
  let(:user) { User.create!(email: "email@example.com") }
  let(:action_movie) { user.campaigns.create!(name: "Action Movie") }
  let(:fight) { Fight.create!(name: "Museum Battle", description: "The Christening of the [@Immortal Woman](/sites/72f84df7-6dfc-42f3-8d55-dba8e40d3190), featuring [@Huan Ken](/characters/2bb9d3d6-3255-4d81-b7c4-64b17b95bbc5), King of the [@Thunder Pagoda](/factions/d9bc6c2f-ebe1-4300-a836-dcb36e6454ab)", campaign_id: action_movie.id, sequence: 1) }
  let(:other_fight) { Fight.create!(name: "Other Fight", campaign_id: action_movie.id, sequence: 1) }

  before(:each) do
    fight.fight_events.create!(event_type: "fight_started", description: "Fight started", details: {fight_id: fight.id})
  end

  context "with no shots or characters" do
    let(:expected) do
      <<-TEXT
# Museum Battle
The Christening of the Immortal Woman, featuring Huan Ken, King of the Thunder Pagoda

## Sequence 1

Fight started
      TEXT
    end

    it "shows fight" do
      response = FightPoster.show(fight)
      puts response
      expect(response).to eq(expected)
    end
  end

  context "with HTML in the description" do
    let(:expected) do
      <<-TEXT
# Museum Battle
Fight to recover the **artifact**

## Sequence 1

Fight started
      TEXT
    end

    before(:each) do
      fight.update(description: "<p>Fight to recover the <strong>artifact</strong></p>")
    end

    it "shows fight with markdown description" do
      response = FightPoster.show(fight)
      puts response
      expect(response).to eq(expected)
    end
  end

  context "with one character" do
    before(:each) do
      brick = Character.create!(name: "Brick Manly", action_values: {"Type" => "PC", "Guns" => 15, "Defense" => 14, "Toughness" => 7, "Speed" => 7, "Fortune" => 7, "Max Fortune" => 7}, campaign_id: action_movie.id)
      fight.fight_events.create!(event_type: "character_added", description: "Character #{brick.name} added", details: {fight_id: fight.id, character: { id: brick.id, name: brick.name }})
      fight.shots.create!(character: brick, shot: 12)
    end

    let(:expected) do
      <<-TEXT
# Museum Battle
The Christening of the Immortal Woman, featuring Huan Ken, King of the Thunder Pagoda

## Sequence 1
## Shot 12
- **Brick Manly** 
 Guns 15 Defense 14 Fortune 7/7 Toughness 7 Speed 7

Character Brick Manly added
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
      fight.shots.create!(character: brick, shot: 12)
      serena = Character.create!(name: "Serena", action_values: {"Type" => "PC", "MainAttack" => "Sorcery", "FortuneType" => "Magic", "Sorcery" => 14, "Defense" => 13, "Toughness" => 7, "Speed" => 6, "Fortune" => 5, "Max Fortune" => 7}, campaign_id: action_movie.id, impairments: 1)
      fight.fight_events.create!(event_type: "attack", description: "#{brick.name} attacked #{serena.name} doing 12 Wounds and spent 3 Shots", details: {fight_id: fight.id, character: { id: brick.id, name: brick.name }, target: { id: serena.id, name: serena.name }, wounds: 12, shots_spent: 3 })
      fight.shots.create!(character: serena, shot: 14)
    end

    let(:expected) do
      <<-TEXT
# Museum Battle
The Christening of the Immortal Woman, featuring Huan Ken, King of the Thunder Pagoda

## Sequence 1
## Shot 14
- **Serena** 
 (1 Impairment)
 Sorcery 13* Defense 12* Magic 5/7 Toughness 7 Speed 6
## Shot 12
- **Brick Manly** 
 Guns 15 Defense 14 Fortune 7/7 Toughness 7 Speed 7

Brick Manly attacked Serena doing 12 Wounds and spent 3 Shots
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
      ninja = Character.create!(name: "Ninja", action_values: {"Type" => "Mook", "Guns" => 8, "Defense" => 13, "Toughness" => 7, "Speed" => 6}, campaign_id: action_movie.id)
      # PC
      brick = Character.create!(name: "Brick Manly", action_values: {"Type" => "PC", "Guns" => 15, "Defense" => 14, "Toughness" => 7, "Speed" => 7, "Fortune" => 7, "Max Fortune" => 7}, campaign_id: action_movie.id)
      # PC
      serena = Character.create!(name: "Serena", action_values: {"Type" => "PC", "MainAttack" => "Sorcery", "FortuneType" => "Magic", "Sorcery" => 14, "Defense" => 13, "Toughness" => 7, "Speed" => 6, "Fortune" => 5, "Max Fortune" => 7, "Wounds" => 39}, campaign_id: action_movie.id, impairments: 2)

      red_ninja_shot = fight.shots.create!(character: ninja, shot: 5)
      blue_ninja_shot = fight.shots.create!(character: ninja, shot: 10)
      green_ninja_shot = fight.shots.create!(character: ninja, shot: nil)
      fight.shots.create!(character: jawbuster, shot: 10)
      fight.shots.create!(character: hitman, shot: 9)
      fight.shots.create!(character: shing, shot: 10)
      brick_in_fight = fight.shots.create!(character: brick, shot: 12)
      serena_in_fight = fight.shots.create!(character: serena, shot: 14)
      fight.shots.create!(character: thunder_king, shot: 12)

      brick_in_other_fight = other_fight.shots.create!(character: brick, shot: 12)

      brick_in_fight.character_effects.create!(:name=>"Bonus", :description=>"Got lucky", :severity=>"info", :action_value=>"MainAttack", :change=>"+1")
      brick_in_fight.character_effects.create!(:name=>"Blinded", :description=>"", :severity=>"error", :action_value=>"Defense", :change=>"-1")
      brick_in_other_fight.character_effects.create!(:name=>"Effect in Other Fight", :description=>"", :severity=>"error", :action_value=>"Defense", :change=>"-1")
      serena_in_fight.character_effects.create!(name: "Feeling weird")

      fight.effects.create!(name: "Shadow of the Sniper", description: "+1 Attack", severity: "success", start_sequence: 1, end_sequence: 2, start_shot: 14, end_shot: 14)
      fight.effects.create!(name: "Some effect", description: "", severity: "error", start_sequence: 1, end_sequence: 2, start_shot: 16, end_shot: 16)
      fight.effects.create!(name: "Some other effect", description: "", severity: "success", start_sequence: 1, end_sequence: 2, start_shot: 9, end_shot: 9)

      fight.fight_events.create!(event_type: "attack", description: "#{brick.name} attacked #{serena.name} doing 12 Wounds and spent 3 Shots", details: {fight_id: fight.id, character: { id: brick.id, name: brick.name }, target: { id: serena.id, name: serena.name }, wounds: 12, shots_spent: 3 })
    end

    let(:expected) do
      <<-TEXT
# Museum Battle
The Christening of the Immortal Woman, featuring Huan Ken, King of the Thunder Pagoda

## Sequence 1
```diff
- Some effect (until sequence 2, shot 16)
+ Shadow of the Sniper: +1 Attack (until sequence 2, shot 14)
```
## Shot 14
- **Serena** 
 39 Wounds (2 Impairments)
 Sorcery 12* Defense 11* Magic 5/7 Toughness 7 Speed 6
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
 Guns 15 Defense 14 Toughness 7 Speed 7
- **Ninja** 
## Shot 9
- **Hitman** 
## Shot 5
- **Ninja** 

Brick Manly attacked Serena doing 12 Wounds and spent 3 Shots
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

  context "with characters and vehicles" do
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
      # Boss Vehicle
      boss_vehicle = Vehicle.create!(name: "Boss Vehicle", action_values: {"Type" => "Boss", "Acceleration" => 7, "Handling" => 10, "Squeal" => 12, "Frame" => 8, "Crunch" => 10, "Condition Points" => 10, "Chase Points" => 24, "Pursuer" => "true", "Position" => "far"}, campaign_id: action_movie.id)
      # PC Vehicle
      pc_vehicle = Vehicle.create!(name: "PC Vehicle", action_values: {"Type" => "PC", "Acceleration" => 7, "Handling" => 10, "Squeal" => 12, "Frame" => 8, "Crunch" => 10, "Condition Points" => 14, "Chase Points" => 12, "Pursuer" => "false", "Position" => "far"}, campaign_id: action_movie.id)
      # PC Vehicle
      mini = Vehicle.create!(name: "PC Mini", impairments: 1, action_values: {"Type" => "PC", "Acceleration" => 7, "Handling" => 10, "Squeal" => 12, "Frame" => 8, "Crunch" => 10, "Condition Points" => 26, "Chase Points" => 19, "Pursuer" => "false", "Position" => "near"}, campaign_id: action_movie.id)

      fight.shots.create!(character: mook, shot: nil)
      fight.shots.create!(character: jawbuster, shot: 10)
      fight.shots.create!(character: hitman, shot: 9)
      fight.shots.create!(character: shing, shot: 10)
      brick_in_fight = fight.shots.create!(character: brick, shot: 12, location: "Control Room")
      serena_in_fight = fight.shots.create!(character: serena, shot: 14)
      fight.shots.create!(character: thunder_king, shot: 12)

      boss_vehicle_in_fight = fight.shots.create!(vehicle: boss_vehicle, shot: 10)
      pc_vehicle_in_fight = fight.shots.create!(vehicle: pc_vehicle, shot: 8, location: "Highway")
      fight.shots.create!(vehicle: mini, shot: 8)

      brick_in_other_fight = other_fight.shots.create!(character: brick, shot: 12)

      brick_in_fight.character_effects.create!(:name=>"Bonus", :description=>"Got lucky", :severity=>"info", :action_value=>"MainAttack", :change=>"+1")
      brick_in_fight.character_effects.create!(:name=>"Blinded", :description=>"", :severity=>"error", :action_value=>"Defense", :change=>"-1")
      brick_in_other_fight.character_effects.create!(:name=>"Effect in Other Fight", :description=>"", :severity=>"error", :action_value=>"Defense", :change=>"-1")
      serena_in_fight.character_effects.create!(name: "Feeling weird")

      boss_vehicle_in_fight.character_effects.create!(:name=>"Bonus", :description=>"Got lucky", :severity=>"info", :action_value=>"Acceleration", :change=>"+1")
      pc_vehicle_in_fight.character_effects.create!(:name=>"Blinded", :description=>"", :severity=>"error", :action_value=>"Handling", :change=>"-1")

      fight.effects.create!(name: "Shadow of the Sniper", description: "+1 Attack", severity: "success", start_sequence: 1, end_sequence: 2, start_shot: 14, end_shot: 14)
      fight.effects.create!(name: "Some effect", description: "", severity: "error", start_sequence: 1, end_sequence: 2, start_shot: 16, end_shot: 16)
      fight.effects.create!(name: "Some other effect", description: "", severity: "success", start_sequence: 1, end_sequence: 2, start_shot: 9, end_shot: 9)

      fight.fight_events.create!(event_type: "attack", description: "#{brick.name} attacked #{serena.name} doing 12 Wounds and spent 3 Shots", details: {fight_id: fight.id, character: { id: brick.id, name: brick.name }, target: { id: serena.id, name: serena.name }, wounds: 12, shots_spent: 3 })
    end

    let(:expected) do
      <<-TEXT
# Museum Battle
The Christening of the Immortal Woman, featuring Huan Ken, King of the Thunder Pagoda

## Sequence 1
```diff
- Some effect (until sequence 2, shot 16)
+ Shadow of the Sniper: +1 Attack (until sequence 2, shot 14)
```
## Shot 14
- **Serena** 
 39 Wounds (2 Impairments)
 Sorcery 12* Defense 11* Magic 5/7 Toughness 7 Speed 6
  ```diff
 Feeling weird
 ```
## Shot 12
- **Thunder King** 
- **Brick Manly** (Control Room) 
 Guns 15 Defense 14 Fortune 7/7 Toughness 7 Speed 7
  ```diff
 Bonus: (Got lucky) Guns +1
 - Blinded: Defense -1
 ```
## Shot 10
- **Ugly Shing** 
- **Jawbuster** 
 12 Wounds
 Guns 15 Defense 14 Toughness 7 Speed 7
- **Boss Vehicle** 
 Pursuer - far
## Shot 9
- **Hitman** 
## Shot 8
- **PC Vehicle** (Highway) 
 Evader - far
 12 Chase 14 Condition Points
 Acceleration 7 Handling 10 Squeal 12 Frame 8
  ```diff
 - Blinded: Handling -1
 ```
- **PC Mini** 
 Evader - near
 19 Chase 26 Condition Points (1 Impairment)
 Acceleration 7 Handling 10 Squeal 12 Frame 8

Brick Manly attacked Serena doing 12 Wounds and spent 3 Shots
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
