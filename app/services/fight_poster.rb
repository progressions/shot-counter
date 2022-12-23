
module FightPoster
  include Rails.application.routes.url_helpers

  class << self
    include Rails.application.routes.url_helpers

    def post_to_discord(fight)
      Bot.send_message(ChannelID, message(fight))
    end

    def message(fight)
      message = <<-TEXT
        A new fight has been created: #{fight.name}
        #{url(fight)}
TEXT
    end

    def url(fight)
      api_v1_fight_url(fight, host: Rails.application.config.action_mailer.default_url_options[:host], protocol: 'https')
    end

  end
end
