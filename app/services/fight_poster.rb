
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
      opts = Rails.application.config.action_mailer.default_url_options
      port = opts[:port] ? ":#{opts[:port]}" : nil
      "#{opts[:protocol]}://#{opts[:host]}#{port}/fights/#{fight.id}"
    end

  end
end
