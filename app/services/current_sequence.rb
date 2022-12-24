module CurrentSequence
  class << self

    def get
      redis.get("current_sequence") || 1
    end

    def set(value)
      redis.set("current_sequence", value)
    end

    private

    def redis
      @redis ||= Redis.new
    end

  end
end
