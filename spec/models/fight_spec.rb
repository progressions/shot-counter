require "rails_helper"

RSpec.describe Fight, type: :model do
  before(:each) do
    @user = User.create!(email: "email@example.com")
    @action_movie = @user.campaigns.create!(name: "Action Movie")
  end

  it "has a shot order with one character" do
    fight = Fight.create!(name: "Fight", campaign_id: @action_movie.id)
    brick = Character.create!(name: "Brick Manly", action_values: {"Type" => "PC", "Guns" => 15, "Defense" => 14, "Toughness" => 7, "Speed" => 7, "Fortune" => 7}, campaign_id: @action_movie.id)
    fight.shots.create!(character: brick, shot: 12)
    expected = [[12, ["Brick Manly"]]]
    expect(fight.shot_order.map { |shot, chars| [shot, chars.map { |c| c[:name] }] }).to eq(expected)
  end

  it "includes shot ID" do
    fight = Fight.create!(name: "Fight", campaign_id: @action_movie.id)
    brick = Character.create!(name: "Brick Manly", action_values: {"Type" => "PC", "Guns" => 15, "Defense" => 14, "Toughness" => 7, "Speed" => 7, "Fortune" => 7}, campaign_id: @action_movie.id)
    shot = fight.shots.create!(character: brick, shot: 12)
    expected = [[12, [shot.id]]]
    expect(fight.shot_order.map { |shot, chars| [shot, chars.map { |c| c[:shot_id] }] }).to eq(expected)
  end

  it "has a shot order with two PCs, orders them by Speed" do
    fight = Fight.create!(name: "Fight", campaign_id: @action_movie.id)
    brick = Character.create!(name: "Brick Manly", action_values: {"Type" => "PC", "Guns" => 15, "Defense" => 14, "Toughness" => 7, "Speed" => 7, "Fortune" => 7}, campaign_id: @action_movie.id)
    serena = Character.create!(name: "Serena", action_values: {"Type" => "PC", "Guns" => 14, "Defense" => 13, "Toughness" => 7, "Speed" => 6, "Fortune" => 7}, campaign_id: @action_movie.id)
    fight.shots.create!(character: brick, shot: 12)
    fight.shots.create!(character: serena, shot: 12)
    expected = [[12, ["Brick Manly", "Serena"]]]
    expect(fight.shot_order.map { |shot, chars| [shot, chars.map { |c| c[:name] }] }).to eq(expected)
  end

  it "has a short order with hidden characters, orders them last" do
    fight = Fight.create!(name: "Fight", campaign_id: @action_movie.id)
    # Uber-Boss
    thunder_king = Character.create!(name: "Thunder King", action_values: {"Type" => "Uber-Boss", "Guns" => 18, "Defense" => 17, "Toughness" => 9, "Speed" => 8}, campaign_id: @action_movie.id)
    # PC
    brick = Character.create!(name: "Brick Manly", action_values: {"Type" => "PC", "Guns" => 15, "Defense" => 14, "Toughness" => 7, "Speed" => 7, "Fortune" => 7}, campaign_id: @action_movie.id)
    # Boss
    shing = Character.create!(name: "Ugly Shing", action_values: {"Type" => "Boss", "Guns" => 15, "Defense" => 14, "Toughness" => 7, "Speed" => 7}, campaign_id: @action_movie.id)
    # Featured Foe
    hitman = Character.create!(name: "Hitman", action_values: {"Type" => "Featured Foe", "Guns" => 15, "Defense" => 14, "Toughness" => 7, "Speed" => 7}, campaign_id: @action_movie.id)
    # Ally
    jawbuster = Character.create!(name: "Jawbuster", action_values: {"Type" => "Ally", "Guns" => 15, "Defense" => 14, "Toughness" => 7, "Speed" => 7}, campaign_id: @action_movie.id)
    # Mook
    mook = Character.create!(name: "Ninja", action_values: {"Type" => "Mook", "Guns" => 8, "Defense" => 13, "Toughness" => 7, "Speed" => 6}, campaign_id: @action_movie.id)

    fight.shots.create!(character: mook, shot: 12)
    fight.shots.create!(character: jawbuster, shot: 12)
    fight.shots.create!(character: hitman, shot: 10)
    fight.shots.create!(character: shing, shot: nil)
    fight.shots.create!(character: brick, shot: nil)
    fight.shots.create!(character: thunder_king, shot: 0)

    expect(fight.shot_order.map { |shot, chars| [shot, chars.map { |c| c[:name] }] }).to eq([[12, ["Jawbuster", "Ninja"]], [10, ["Hitman"]], [0, ["Thunder King"]], [nil, ["Brick Manly", "Ugly Shing"]]])
  end

  it "orders characters by Type" do
    fight = Fight.create!(name: "Fight", campaign_id: @action_movie.id)
    # Uber-Boss
    thunder_king = Character.create!(name: "Thunder King", action_values: {"Type" => "Uber-Boss", "Guns" => 18, "Defense" => 17, "Toughness" => 9, "Speed" => 8}, campaign_id: @action_movie.id)
    # PC
    brick = Character.create!(name: "Brick Manly", action_values: {"Type" => "PC", "Guns" => 15, "Defense" => 14, "Toughness" => 7, "Speed" => 7, "Fortune" => 7}, campaign_id: @action_movie.id)
    # Boss
    shing = Character.create!(name: "Ugly Shing", action_values: {"Type" => "Boss", "Guns" => 15, "Defense" => 14, "Toughness" => 7, "Speed" => 7}, campaign_id: @action_movie.id)
    # Featured Foe
    hitman = Character.create!(name: "Hitman", action_values: {"Type" => "Featured Foe", "Guns" => 15, "Defense" => 14, "Toughness" => 7, "Speed" => 7}, campaign_id: @action_movie.id)
    # Ally
    jawbuster = Character.create!(name: "Jawbuster", action_values: {"Type" => "Ally", "Guns" => 15, "Defense" => 14, "Toughness" => 7, "Speed" => 7}, campaign_id: @action_movie.id)
    # Mook
    mook = Character.create!(name: "Ninja", action_values: {"Type" => "Mook", "Guns" => 8, "Defense" => 13, "Toughness" => 7, "Speed" => 6}, campaign_id: @action_movie.id)

    fight.shots.create!(character: mook, shot: 12)
    fight.shots.create!(character: jawbuster, shot: 12)
    fight.shots.create!(character: hitman, shot: 12)
    fight.shots.create!(character: shing, shot: 12)
    fight.shots.create!(character: brick, shot: 12)
    fight.shots.create!(character: thunder_king, shot: 12)

    # expect(fight.shot_order).to eq([[12, [thunder_king, brick, shing, hitman, jawbuster, mook]]].as_json)
    expected = [[12, ["Thunder King", "Brick Manly", "Ugly Shing", "Hitman", "Jawbuster", "Ninja"]]]
    expect(fight.shot_order.map { |shot, chars| [shot, chars.map { |c| c[:name] }] }).to eq(expected)
  end

  it "orders characters before vehicles" do
    fight = Fight.create!(name: "Fight", campaign_id: @action_movie.id)
    # Vehicle
    truck = Vehicle.create!(name: "Battletruck", action_values: {"Type" => "Featured Foe", "Acceleration" => 6}, campaign_id: @action_movie.id)
    # PC
    brick = Character.create!(name: "Brick Manly", action_values: {"Type" => "PC", "Guns" => 15, "Defense" => 14, "Toughness" => 7, "Speed" => 7, "Fortune" => 7}, campaign_id: @action_movie.id)

    fight.shots.create!(vehicle: truck, shot: 12)
    fight.shots.create!(character: brick, shot: 12)

    expected = [[12, ["Brick Manly", "Battletruck"]]]
    expect(fight.shot_order.map { |shot, chars| [shot, chars.map { |c| c[:name] }] }).to eq(expected)
  end

  it "orders by Speed, considering impairments" do
    fight = Fight.create!(name: "Fight", campaign_id: @action_movie.id)
    brick = Character.create!(name: "Brick Manly", action_values: {"Type" => "PC", "Guns" => 15, "Defense" => 14, "Toughness" => 7, "Speed" => 7, "Fortune" => 7}, impairments: 2, campaign_id: @action_movie.id)
    serena = Character.create!(name: "Serena", action_values: {"Type" => "PC", "Guns" => 14, "Defense" => 13, "Toughness" => 7, "Speed" => 6, "Fortune" => 7}, campaign_id: @action_movie.id)
    fight.shots.create!(character: brick, shot: 12)
    fight.shots.create!(character: serena, shot: 12)
    expected = [[12, ["Serena", "Brick Manly"]]]
    expect(fight.shot_order.map { |shot, chars| [shot, chars.map { |c| c[:name] }] }).to eq(expected)
  end

  context "mooks" do
    let(:fight) { Fight.create!(name: "Fight", campaign_id: @action_movie.id, sequence: 1) }
    let(:grunts) { Character.create!(name: "Grunts", action_values: {"Type" => "Mook", "Guns" => 8, "Defense" => 13, "Toughness" => 7, "Speed" => 6}, campaign_id: @action_movie.id) }
    let!(:grunts_shot) { fight.shots.create!(character: grunts, shot: 12) }
    let!(:mook) { grunts_shot.create_mook(count: 25) }

    it "shows mook count" do
      expected = [[12, [25]]]
      expect(fight.shot_order.map { |shot, chars| [shot, chars.map { |c| c[:count] }] }).to eq(expected)
    end

    it "shows a mook with a custom color" do
      mook.update(color: "red")
      expected = [[12, ["red"]]]
      expect(fight.shot_order.map { |shot, chars| [shot, chars.map { |c| c[:color] }] }).to eq(expected)
    end
  end

  context "effects" do
    let(:fight) { Fight.create!(name: "Fight", campaign_id: @action_movie.id, sequence: 1) }
    let(:brick) { Character.create!(name: "Brick Manly", action_values: {"Type" => "PC", "Guns" => 15, "Defense" => 14, "Toughness" => 7, "Speed" => 7, "Fortune" => 7}, campaign_id: @action_movie.id) }
    let!(:brick_shot) { fight.shots.create!(character: brick, shot: 12) }
    let!(:effect) {
      fight.effects.create!(name: "Effect", start_sequence: 1, end_sequence: 2, start_shot: 15, end_shot: 15, severity: "info")
    }

    # Effect is active between sequence 1, shot 15 and sequence 2, shot 15

    it "sequence 1, shot 16, effect is not active" do
      brick_shot.update(shot: 16)
      expect(fight.active_effects).to eq([])
    end

    it "sequence 1, shot 12, effect is active" do
      brick_shot.update(shot: 12)
      expect(fight.active_effects).to eq([effect])
    end

    it "sequence 1, shot 5, effect is active" do
      brick_shot.update(shot: 5)
      expect(fight.active_effects).to eq([effect])
    end

    it "sequence 2, shot 16, effect is active" do
      fight.update(sequence: 2)
      brick_shot.update(shot: 16)
      expect(fight.active_effects).to eq([effect])
    end

    it "sequence 2, shot 15, effect is not active" do
      fight.update(sequence: 2)
      brick_shot.update(shot: 15)
      expect(fight.active_effects).to eq([])
    end

    it "sequence 2, shot 1, effect is not active" do
      fight.update(sequence: 2)
      brick_shot.update(shot: 10)
      expect(fight.active_effects).to eq([])
    end
  end
end
