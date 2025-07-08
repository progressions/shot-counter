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
      @description_markdown = clean_markup_string(markdown_description(fight))
      filename = Rails.root.join("app", "views", "fights", "show.md.erb")
      ERB.new(filename.read, trim_mode: "-").result(binding)
    end

    def markdown_description(fight)
      description = fight.description || ""
      ReverseMarkdown.convert(description)
    end

    def show_character(attributes, fight)
      character = Character.find(attributes[:id])
      render_partial("character", binding)
    end

    def show_vehicle(attributes, fight)
      vehicle = Vehicle.find(attributes[:id])
      render_partial("vehicle", binding)
    end

    def render_partial(filename, binding)
      filename = Rails.root.join("app", "views", "fights", "_#{filename}.md.erb")
      ERB.new(filename.read, trim_mode: "-").result(binding)
    end

    def action_value(character, key, impairments: false)
      if character.action_values[key].to_i > 0
        asterisk = (impairments && character.impairments.to_i > 0) ? "*" : ""
        value = character.action_values[key].to_i - (impairments ? character.impairments.to_i : 0)

        "#{key} #{value}#{asterisk}"
      end
    end

    def fortune_value(character)
      if character.action_values["Max Fortune"].to_i > 0
        current_fortune = character.action_values["Fortune"].to_i
        max_fortune = character.action_values["Max Fortune"].to_i

        "#{character.action_values["FortuneType"]} #{current_fortune}/#{max_fortune}"
      end
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

    def find_location(attributes)
      @location = Shot.find_by(id: attributes[:shot_id])&.location
      if @location
        " (#{@location})"
      end
    end

    def strip_html_p_to_br(html)
      # Parse HTML with Nokogiri
      doc = Nokogiri::HTML.fragment(html)

      # Replace <p> tags with content and newline
      doc.css('p').each do |p|
        p.replace(p.text + "\n")
      end

      # Strip all other HTML tags and get text
      text = doc.text.strip

      # Normalize newlines
      text.lines.map(&:strip).reject(&:empty?).join("\n")
    end

    def clean_markup_string(str)
      str.gsub(/\[@([^]\]]+)\]\(\/[^)]+\)/, '\1')
    end
  end
end
