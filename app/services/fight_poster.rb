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
      message << ""
      message << ""
      message << "# #{fight.name}"
      message << "### Sequence #{fight.sequence}"
      message.join("\n")
    end

    def verbose_shots(fight)
      message = []
      fight.shot_order.each do |shot, characters|
        shot_msg = []

        shot_msg << "## Shot #{shot.to_i}"

        shot_msg << characters.map do |character|
          show_character(character)
        end

        message << shot_msg
      end

      message.join("\n")
    end

    private

    def show_character(character)
      char_msg = []
      char_msg << "- **#{character.name}**"

      if character.action_values["Faction"]
        char_msg << "- #{character.action_values["Faction"]}"
      end

      if character.action_values["Type"] == "PC"
        char_msg << show_player_character(character)
      end

      char_msg.join(" ")
    end

    def show_player_character(character)
      [].tap do |msg|
        msg << "\n"

        msg << "#{character.action_values["Wounds"]} Wounds"
        if character.impairments.to_i > 0
          msg << "(-#{character.impairments} impairments)"
        end
        msg << "\n"

        main_attack = character.action_values["MainAttack"]
        secondary_attack = character.action_values["SecondaryAttack"]

        asterisk = character.impairments.to_i > 0 ? "*" : ""
        msg << "#{main_attack} #{character.action_values[main_attack] - character.impairments.to_i}#{asterisk}"
        msg << " / "

        if character.action_values[secondary_attack].to_i > 7
          msg << "#{secondary_attack} #{character.action_values[secondary_attack] - character.impairments.to_i}#{asterisk}"
          msg << " / "
        end

        msg << "Defense #{character.action_values["Defense"] - character.impairments.to_i}#{asterisk}"
        msg << " / "
        msg << "Toughness #{character.action_values["Toughness"] - character.impairments.to_i}#{asterisk}"
        msg << " / "
        msg << "Speed #{character.action_values["Speed"] - character.impairments.to_i}#{asterisk}"
      end
    end

    def terse_shots(fight)
      message = []
      fight.shot_order.each do |shot, characters|
        shot_msg = []

        shot_msg << "\n"
        shot_msg << "```"
        shot_msg << "- Shot #{shot.to_i}"
        shot_msg << "```"

        shot_msg << characters.map do |character|
          char_msg = []
          char_msg << "**#{character.name}**"
          if defense = character.action_values["Defense"]
            char_msg << "(D#{defense - character.impairments.to_i})"
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

  end
end
