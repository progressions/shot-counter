module CurrentFight
  class << self

    def get(server_id)
      current_fight_id = redis.get("current_fight_id:#{server_id}")
      fight = Fight.find_by(id: current_fight_id)
    end

    def set(server_id, fight=nil)
      redis.set("current_fight_id:#{server_id}", fight&.id)
    end

    # Add functions to save and get current character for a username

    private

    def redis
      @redis ||= Redis.new
    end

  end
end
