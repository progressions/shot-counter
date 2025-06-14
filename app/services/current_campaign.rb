module CurrentCampaign
  class << self
    def get(user: nil, server_id: nil)
      if user
        current_campaign = user.current_campaign
        set(user: user, server_id: server_id, campaign: current_campaign)
      else
        json = redis.get("current_campaign:#{server_id}")
        if json.present?
          campaign_info = JSON.parse(json)
          current_campaign = Campaign.find_by(id: campaign_info["campaign_id"])
        end
      end
      current_campaign
    end

    def set(user: nil, server_id: nil, campaign: nil)
      if user
        user.current_campaign = campaign
        user.save
      end
      redis.set("current_campaign:#{server_id}", {campaign_id: campaign&.id}.to_json)
    end

    private

    def redis
      @redis ||= Redis.new
    end
  end
end
