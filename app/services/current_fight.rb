# app/models/current_fight.rb
module CurrentFight
  def self.set(server_id:, fight:)
    redis = Redis.new
    redis.set("current_fight:#{server_id}", { fight_id: fight&.id }.to_json)
  end

  def self.get(server_id:)
    redis = Redis.new
    data = redis.get("current_fight:#{server_id}")
    return { fight: nil } unless data

    parsed = JSON.parse(data, symbolize_names: true)
    fight = Fight.find_by(id: parsed[:fight_id])
    { fight: fight }
  end

  def self.get_server_id_for_fight(fight_id)
    redis = Redis.new
    redis.keys("current_fight:*").each do |key|
      data = redis.get(key)
      next unless data
      parsed = JSON.parse(data, symbolize_names: true)
      return key.split(":").last.to_i if parsed[:fight_id] == fight_id
    end
    nil
  end
end
