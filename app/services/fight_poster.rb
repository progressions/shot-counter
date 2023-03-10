module FightPoster
  class << self
    include Rails.application.routes.url_helpers

    def post_to_discord(fight)
      return unless defined?(Bot)
      Bot.send_message(ChannelID, message(fight))
    end

    def post_shots(fight)
      Bot.send_message(ChannelID, shots(fight))
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

    def shots(fight)
      message = []
      message << header(fight)
      # message << terse_shots(fight)
      message << verbose_shots(fight)

      message.join("\n")
    end

    def header(fight)
      message = []
      message << "FIGHT"
      message << ""
      message << "**#{fight.name}**"
      message << "```diff"
      message << "- (sequence #{CurrentSequence.get})"
      message << "```"
      message.join("\n")
    end

    def terse_shots(fight)
      message = []
      fight.shot_order.each do |shot, characters|
        shot_msg = []
        shot_msg << "Shot #{shot.to_i}"
        shot_msg << characters.map do |character|
          char_msg = []
          char_msg << "**#{character.name}**"
          if character.defense
            char_msg << "(D#{character.defense.to_i - character.impairments.to_i})"
          end
          if character.impairments.to_i > 0
            char_msg << "(-#{character.impairments})"
          end
          char_msg.join(" ")
        end.join(",")
        message << shot_msg.join(" ")
      end

      message.join("\n")
    end

    def verbose_shots(fight)
      message = []
      fight.shot_order.each do |shot, characters|
        shot_msg = []
        shot_msg << "Shot #{shot.to_i}"
        shot_msg << characters.map do |character|
          char_msg = ["-"]
          char_msg << "**#{character.name}**"
          if character.defense
            char_msg << "(D#{character.defense.to_i - character.impairments.to_i})"
          end
          if character.impairments.to_i > 0
            char_msg << "(-#{character.impairments})"
          end
          char_msg.join(" ")
        end.join("\n")
        message << shot_msg
      end

      message.join("\n")
    end

  end
end
