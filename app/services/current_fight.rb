module CurrentFight
  class << self

    def get(server_id:)
      json = redis.get("current_fight_id:#{server_id}")
      if json.nil?
        return {
          fight: nil,
          channel_id: nil
        }
      end
      data = JSON.parse(json).with_indifferent_access
      fight = Fight.find_by(id: data[:fight_id])
      {
        fight: fight,
        channel_id: data[:channel_id]
      }
    end

    def set(server_id:, channel_id:, fight: nil)
      data = payload(fight || Fight.create, channel_id)
      redis.set("current_fight_id:#{server_id}", data.to_json)
      set_channel_id(server_id: server_id, fight_id: data[:fight_id], channel_id: channel_id)
    end

    def get_channel_id(server_id:, fight:)
      redis.get("channel_id:#{server_id}:#{fight.id}")
    end

    def set_channel_id(server_id:, fight_id:, channel_id: nil)
      redis.set("channel_id:#{server_id}:#{fight_id}", channel_id)
    end

    # Add functions to save and get current character for a username

    private

    def payload(fight, channel_id)
      {
        fight_id: fight&.id,
        channel_id: channel_id
      }
    end

    def redis
      @redis ||= Redis.new
    end

  end
end
