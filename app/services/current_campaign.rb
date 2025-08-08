module CurrentCampaign
  class << self
    def get(user: nil, server_id: nil)
      raise ArgumentError, "Either user or server_id must be provided" unless user || server_id
      raise ArgumentError, "Cannot provide both user and server_id" if user && server_id

      if user
        current_campaign = Campaign
          .includes(:image_positions, :user)
          .with_attached_image
          .find_by(id: user.current_campaign_id)

        set(user: user, campaign: current_campaign)
      else
        json = redis.get("current_campaign:#{server_id}")
        if json.present?
          campaign_info = JSON.parse(json)
          current_campaign = Campaign
            .includes(:image_positions)
            .with_attached_image
            .find_by(id: campaign_info["campaign_id"])
        end
      end
      current_campaign
    end

    def set(user: nil, server_id: nil, campaign: nil)
      raise ArgumentError, "Either user or server_id must be provided" unless user || server_id

      if user
        user.current_campaign = campaign
        user.save

        user_info = {
          "campaign_id" => campaign&.id
        }
        redis.set("user_#{user.id}", user_info.to_json)
      end

      if server_id
        server_info = {
          "campaign_id" => campaign&.id
        }
        redis.set("current_campaign:#{server_id}", server_info.to_json)
      end
    end

    private

    def redis
      @redis ||= Redis.new
    end
  end
end
