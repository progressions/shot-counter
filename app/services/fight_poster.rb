module FightPoster
  class << self
    SEVERITIES = {
      "info" => "",
      "error" => "- ",
      "success" => "+ ",
      "warning" => "! "
    }

    include Rails.application.routes.url_helpers
    include ActiveSupport::Inflector

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

    def show_character(character)
      @character = character
      filename = Rails.root.join("app", "views", "fights", "_character.md.erb")
      ERB.new(filename.read, trim_mode: "-").result(binding)
    end

    def show_vehicle(vehicle)
      @vehicle = vehicle
      filename = Rails.root.join("app", "views", "fights", "_vehicle.md.erb")
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
        character.action_values["Wounds"].to_i > 0 ? "#{character.action_values["Wounds"]} Wounds" : nil,
        character.impairments.to_i > 0 ? "(#{character.impairments} #{impairments})" : nil
      ].compact.join(" ")
    end

    def chase_points_and_impairments(vehicle)
      impairments = "Impairment".pluralize(vehicle.impairments.to_i)
      [
        vehicle.action_values["Chase Points"].to_i > 0 ? "#{vehicle.action_values["Chase Points"]} Chase" : nil,
        vehicle.action_values["Condition Points"].to_i > 0 ? "#{vehicle.action_values["Condition Points"]} Condition Points" : nil,
        vehicle.impairments.to_i > 0 ? "(#{vehicle.impairments} #{impairments})" : nil
      ].compact.join(" ")
    end

    def character_effect(effect)
      action_value = effect.action_value
      if action_value == "MainAttack"
        action_value = effect.character.action_values["MainAttack"]
      end

      name = effect.name
      description = effect.description.present? ? " (#{effect.description})" : ""
      status = SEVERITIES[effect.severity]

      if description.present? || effect.change.present?
        name = "#{name}:"
      end

      "#{status}#{name}#{description} #{action_value} #{effect.change}".strip
    end

    def fight_effect(effect)
      name = effect.name
      description = effect.description.present? ? " #{effect.description}" : ""
      status = SEVERITIES[effect.severity]

      if description.present?
        name = "#{name}:"
      end

      "#{status}#{name}#{description} (until sequence #{effect.end_sequence}, shot #{effect.end_shot})"
    end

  end
end
