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
        boxcars: boxcars,
        rolled_at: DateTime.now
      }
    end

    def discord(swerve, username=nil)
      message = []
      message << "# #{swerve[:total]}"
      message << "BOXCARS!" if swerve[:boxcars]
      message << "```diff"
      message << "+ #{swerve[:positives][:sum]} (#{swerve[:positives][:rolls].join(", ")})"
      message << "- #{swerve[:negatives][:sum]} (#{swerve[:negatives][:rolls].join(", ")})"
      message << "```"
      message.join("\n")
    end

    def save_swerve(swerve, username)
      redis.lpush("rolls #{username}", swerve.to_json)
    end

    def load_swerves(username)
      redis.lrange("rolls #{username}", 0, -1).map do |swerve|
        JSON.parse(swerve, symbolize_names: true)
      end
    end

    def clear_swerves(username)
      redis.del("rolls #{username}")
    end

    private

    def redis
      @redis ||= Redis.new
    end
  end
end
