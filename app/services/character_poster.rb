module CharacterPoster
  class << self
    def set_character(user_id, character_id)
      redis.set("character:#{user_id}", character_id)
    end

    def get_character(user_id)
      id = redis.get("character:#{user_id}")
      Character.find(id)
    end

    def show(character)
      @character = character
      filename = Rails.root.join("app", "views", "characters", "show.md.erb")
      ERB.new(filename.read, trim_mode: "-").result(binding)
    end

    private

    def redis
      @redis ||= Redis.new
    end
  end
end
