module FightPoster
  extend ActiveSupport::Inflector

  class << self
    include Rails.application.routes.url_helpers

    def post_to_discord(fight)
      return unless defined?(Bot)
      Bot.send_message(ChannelID, message(fight))
    end

    def post_shots(fight)
      Bot.send_message(ChannelID, show(fight))
    end

    def shots(fight)
      show(fight)
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

    def show(fight)
      @fight = fight
      filename = Rails.root.join("app", "views", "fights", "show.md.erb")
      ERB.new(filename.read, trim_mode: "-").result(binding)
    end

    def action_value(character, key)
      if character.action_values[key].to_i > 0
        asterisk = character.impairments.to_i > 0 ? "*" : ""
        value = character.action_values[key].to_i - character.impairments.to_i

        "#{key} #{value}#{asterisk}"
      end
    end

    def fortune_value(character)
      asterisk = character.impairments.to_i > 0 ? "*" : ""
      current_fortune = character.action_values["Fortune"].to_i - character.impairments.to_i
      max_fortune = character.action_values["Max Fortune"].to_i - character.impairments.to_i

      "#{character.action_values["FortuneType"]} #{current_fortune}/#{max_fortune}#{asterisk}"
    end

    def wounds_and_impairments(character)
      impairments = "Impairment".pluralize(character.impairments.to_i)
      [
        "#{character.action_values["Wounds"]} Wounds",
        character.impairments.to_i > 0 ? "(#{character.impairments} #{impairments})" : nil
      ].compact.join(" ")
    end

  end
end
