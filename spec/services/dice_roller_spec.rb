require 'rails_helper'

RSpec.describe DiceRoller do

  describe ".die_roll" do
    it "rolls a single die" do
      expect(DiceRoller.die_roll).to be_between(1, 6)
    end
  end

  describe ".exploding_die_roll" do
    it "rolls an exploding die" do
      allow(DiceRoller).to receive(:die_roll).and_return(6, 5)
      expect(DiceRoller.exploding_die_roll[:sum]).to eq(11)
    end

    it "rolls multiple exploding sixes" do
      allow(DiceRoller).to receive(:die_roll).and_return(6, 6, 6, 5)
      expect(DiceRoller.exploding_die_roll[:sum]).to eq(23)
    end

    it "rolls many many exploding sixes" do
      allow(DiceRoller).to receive(:die_roll).and_return(6, 6, 6, 6, 6, 6, 6, 6, 6, 5)
      expect(DiceRoller.exploding_die_roll[:sum]).to eq(59)
    end
  end

  describe ".swerve" do
    it "rolls a swerve" do
      allow(DiceRoller).to receive(:die_roll).and_return(5, 1)
      result = DiceRoller.swerve
      expect(result[:positives][:sum]).to eq(5)
      expect(result[:negatives][:sum]).to eq(1)
      expect(result[:total]).to eq(4)
      expect(result[:boxcars]).to eq(false)
    end

    it "rolls a swerve with exploding positives" do
      allow(DiceRoller).to receive(:die_roll).and_return(6, 6, 6, 6, 6, 6, 6, 6, 6, 5, 1)
      result = DiceRoller.swerve
      expect(result[:positives][:sum]).to eq(59)
      expect(result[:negatives][:sum]).to eq(1)
      expect(result[:total]).to eq(58)
      expect(result[:boxcars]).to be_falsey
    end

    it "rolls a swerve with exploding negatives" do
      allow(DiceRoller).to receive(:die_roll).and_return(1, 6, 1)
      result = DiceRoller.swerve
      expect(result[:positives][:sum]).to eq(1)
      expect(result[:negatives][:sum]).to eq(7)
      expect(result[:total]).to eq(-6)
      expect(result[:boxcars]).to be_falsey
    end

    it "rolls boxcars" do
      allow(DiceRoller).to receive(:die_roll).and_return(6, 1, 6, 1)
      result = DiceRoller.swerve
      expect(result[:positives][:sum]).to eq(7)
      expect(result[:negatives][:sum]).to eq(7)
      expect(result[:total]).to eq(0)
      expect(result[:boxcars]).to be_truthy
    end
  end

  describe ".discord" do
    it "posts swerve to discord" do
      allow(DiceRoller).to receive(:die_roll).and_return(6, 1, 6, 1)
      swerve = DiceRoller.swerve
      message = DiceRoller.discord(swerve, "Brick Manly")
      expect(message).to eq("# 0\nBOXCARS!\n```diff\n+ 7 (6, 1)\n- 7 (6, 1)\n```")
    end
  end

  describe ".save" do
    it "saves a swerve in a cache for each user" do
      DiceRoller.clear_swerves("Brick Manly")
      allow(DiceRoller).to receive(:die_roll).and_return(6, 1, 6, 1)
      swerve = DiceRoller.swerve
      DiceRoller.save_swerve(swerve, "Brick Manly")
      expect(DiceRoller.load_swerves("Brick Manly")).to eq([JSON.parse(swerve.to_json, symbolize_names: true)])
    end

    it "saves multiple swerves in a user's cache" do
      DiceRoller.clear_swerves("Brick Manly")
      allow(DiceRoller).to receive(:die_roll).and_return(6, 1, 6, 1)
      swerve1 = DiceRoller.swerve
      DiceRoller.save_swerve(swerve1, "Brick Manly")
      swerve2 = DiceRoller.swerve
      DiceRoller.save_swerve(swerve2, "Brick Manly")
      expect(DiceRoller.load_swerves("Brick Manly")).to eq([JSON.parse(swerve2.to_json, symbolize_names: true), JSON.parse(swerve1.to_json, symbolize_names: true)])
    end

    it "clears cache for a user" do
      DiceRoller.clear_swerves("Brick Manly")
      allow(DiceRoller).to receive(:die_roll).and_return(6, 1, 6, 1)
      swerve = DiceRoller.swerve
      DiceRoller.save_swerve(swerve, "Brick Manly")
      DiceRoller.clear_swerves("Brick Manly")
      expect(DiceRoller.load_swerves("Brick Manly")).to eq([])
    end
  end

end
