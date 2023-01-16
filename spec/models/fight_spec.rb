require "rails_helper"

RSpec.describe Fight, type: :model do
  before(:each) do
    @user = User.create!(email: "email@example.com")
    @action_movie = @user.campaigns.create!(title: "Action Movie")
  end

  it "has a shot order with one character" do
    fight = Fight.create!(name: "Fight", campaign_id: @action_movie.id)
    brick = Character.create!(name: "Brick Manly", action_values: {"Type" => "PC", "Guns" => 15, "Defense" => 14, "Toughness" => 7, "Speed" => 7, "Fortune" => 7}, campaign_id: @action_movie.id)
    fight.fight_characters.create!(character: brick, shot: 12)
    expect(fight.shot_order).to eq([[12, [brick]]])
  end

  it "has a shot order with two PCs, orders them by Speed" do
    fight = Fight.create!(name: "Fight", campaign_id: @action_movie.id)
    brick = Character.create!(name: "Brick Manly", action_values: {"Type" => "PC", "Guns" => 15, "Defense" => 14, "Toughness" => 7, "Speed" => 7, "Fortune" => 7}, campaign_id: @action_movie.id)
    serena = Character.create!(name: "Serena", action_values: {"Type" => "PC", "Guns" => 14, "Defense" => 13, "Toughness" => 7, "Speed" => 6, "Fortune" => 7}, campaign_id: @action_movie.id)
    fight.fight_characters.create!(character: brick, shot: 12)
    fight.fight_characters.create!(character: serena, shot: 12)
    expect(fight.shot_order).to eq([[12, [brick, serena]]])
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

    fight.fight_characters.create!(character: mook, shot: 12)
    fight.fight_characters.create!(character: jawbuster, shot: 12)
    fight.fight_characters.create!(character: hitman, shot: 12)
    fight.fight_characters.create!(character: shing, shot: 12)
    fight.fight_characters.create!(character: brick, shot: 12)
    fight.fight_characters.create!(character: thunder_king, shot: 12)

    expect(fight.shot_order).to eq([[12, [thunder_king, brick, shing, hitman, jawbuster, mook]]])
  end

  it "orders vehicles before characters" do
    fight = Fight.create!(name: "Fight", campaign_id: @action_movie.id)
    # Vehicle
    truck = Vehicle.create!(name: "Battletruck", action_values: {"Type" => "Featured Foe", "Acceleration" => 6}, campaign_id: @action_movie.id)
    # PC
    brick = Character.create!(name: "Brick Manly", action_values: {"Type" => "PC", "Guns" => 15, "Defense" => 14, "Toughness" => 7, "Speed" => 7, "Fortune" => 7}, campaign_id: @action_movie.id)

    fight.fight_characters.create!(vehicle: truck, shot: 12)
    fight.fight_characters.create!(character: brick, shot: 12)

    expect(fight.shot_order).to eq([[12, [brick, truck]]])
  end

  it "orders by Speed, considering impairments" do
    fight = Fight.create!(name: "Fight", campaign_id: @action_movie.id)
    brick = Character.create!(name: "Brick Manly", action_values: {"Type" => "PC", "Guns" => 15, "Defense" => 14, "Toughness" => 7, "Speed" => 7, "Fortune" => 7}, impairments: 2, campaign_id: @action_movie.id)
    serena = Character.create!(name: "Serena", action_values: {"Type" => "PC", "Guns" => 14, "Defense" => 13, "Toughness" => 7, "Speed" => 6, "Fortune" => 7}, campaign_id: @action_movie.id)
    fight.fight_characters.create!(character: brick, shot: 12)
    fight.fight_characters.create!(character: serena, shot: 12)
    expect(fight.shot_order).to eq([[12, [serena, brick]]])
  end
end
