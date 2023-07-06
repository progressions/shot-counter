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
      puts result.inspect
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

  describe ".post_swerve" do
    it "returns a string" do
      allow(DiceRoller).to receive(:die_roll).and_return(5, 1)
      expect(DiceRoller.post_swerve).to eq("Rolling swerve\n# 4\nPositives: 5 (5)\nNegatives: 1 (1)")
    end

    it "returns a roll with boxcars" do
      allow(DiceRoller).to receive(:die_roll).and_return(6, 1, 6, 1)
      expect(DiceRoller.post_swerve).to eq("Rolling swerve\n# 0\nBOXCARS!\nPositives: 7 (6, 1)\nNegatives: 7 (6, 1)")
    end
  end

end
