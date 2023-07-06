module DiceRoller
  class << self
    def die_roll
      rand(1..6)
    end

    def exploding_die_roll
      rolls = []
      roll = die_roll
      rolls << roll
      until (roll != 6)
        result = exploding_die_roll
        roll = result[:sum]
        rolls << result[:rolls].flatten
      end
      {
        sum: rolls.flatten.sum,
        rolls: rolls.flatten
      }
    end

    def swerve
      positives = exploding_die_roll
      negatives = exploding_die_roll
      boxcars = positives[:rolls][0] == 6 && negatives[:rolls][0] == 6

      {
        positives: positives,
        negatives: negatives,
        total: positives[:sum] - negatives[:sum],
        boxcars: boxcars
      }
    end

    def post_swerve
      swerve = DiceRoller.swerve
      message = ["Rolling swerve"]
      message << "# #{swerve[:total]}"
      message << "BOXCARS!" if swerve[:boxcars]
      message << "Positives: #{swerve[:positives][:sum]} (#{swerve[:positives][:rolls].join(", ")})"
      message << "Negatives: #{swerve[:negatives][:sum]} (#{swerve[:negatives][:rolls].join(", ")})"

      message.join("\n")
    end

    def discord(swerve, username=nil)
      message = ["Rolling swerve #{username ? 'for ' + username : ''}"]
      message << "# #{swerve[:total]}"
      message << "BOXCARS!" if swerve[:boxcars]
      message << "```diff"
      message << "+ #{swerve[:positives][:sum]} (#{swerve[:positives][:rolls].join(", ")})"
      message << "- #{swerve[:negatives][:sum]} (#{swerve[:negatives][:rolls].join(", ")})"
      message << "```"
      message.join("\n")
    end
  end
end
