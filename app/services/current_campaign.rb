module CurrentCampaign
  class << self
    def get
      json = redis.get("current_campaign")
      if json.present?
        campaign_info = JSON.parse(json)
        @current_campaign = Campaign.find_by(id: campaign_info["campaign_id"])
      end
    end

    def set(campaign=nil)
      redis.set("current_campaign", {campaign_id: campaign.id}.to_json)
    end

    private

    def redis
      @redis ||= Redis.new
    end
  end
end
