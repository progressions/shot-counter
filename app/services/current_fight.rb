module CurrentFight
  class << self

    def get
      current_fight_id = redis.get("current_fight_id")
      fight = Fight.find_by(id: current_fight_id)
    end

    def set(fight=nil)
      redis.set("current_fight_id", fight&.id)
    end

    private

    def redis
      @redis ||= Redis.new
    end

  end
end
