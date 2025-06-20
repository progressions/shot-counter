class FightChannel < ApplicationCable::Channel
  def subscribed
    fight_id = params[:fight_id]
    stream_from "fight_#{fight_id}"

    # Store user presence
    Rails.logger.info("SOCKETS - User #{current_user.id} subscribed to fight_#{fight_id}")
    redis_key = "fight:#{fight_id}:users"
    redis.sadd(redis_key, current_user.id)
    redis.expire(redis_key, 24 * 60 * 60) # 24-hour TTL to clean up

    # Broadcast updated user list
    broadcast_user_list(fight_id)
  end

  def unsubscribed
    fight_id = params[:fight_id]
    Rails.logger.info("SOCKETS - User #{current_user.id} unsubscribed from fight_#{fight_id}")
    redis_key = "fight:#{fight_id}:users"
    redis.srem(redis_key, current_user.id)

    # Broadcast updated user list
    broadcast_user_list(fight_id)
  end

  private

  def broadcast_user_list(fight_id)
    redis_key = "fight:#{fight_id}:users"
    user_ids = redis.smembers(redis_key)
    users = User.where(id: user_ids).map do |user|
      {
        id: user.id,
        first_name: user.first_name,
        last_name: user.last_name,
        name: "#{user.first_name} #{user.last_name}".strip,
        avatar_url: user.image_url
      }
    end
    Rails.logger.info("SOCKETS - Broadcasting user list for fight_#{fight_id}: #{users.inspect}")
    ActionCable.server.broadcast("fight_#{fight_id}", { users: users })
  end

  def redis
    @redis ||= Redis.new
  end
end
