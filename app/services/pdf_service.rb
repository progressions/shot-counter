require "pdf_forms"

module PdfService
   FIELDS = [
     "Name",
     "Attack Type",
     "Attack",
     "Defense",
     "Toughness",
     "Fortune Type",
     "Fortune",
     "Speed",
     "Schtick 1 Title",
     "Schtick 1 Text",
     "Schtick 2 Title",
     "Schtick 2 Text",
     "Schtick 3 Title",
     "Schtick 3 Text",
     "Schtick 4 Title",
     "Schtick 4 Text",
     "Schtick 5 Title",
     "Schtick 5 Text",
     "Schtick 6 Title",
     "Schtick 6 Text",
     "Schtick 7 Title",
     "Schtick 7 Text",
     "Schtick 8 Title",
     "Schtick 8 Text",
     "Schtick 9 Title",
     "Schtick 9 Text",
     "Schtick 10 Title",
     "Schtick 10 Text",
     "Weapon 1 Name",
     "Weapon 1 Damage",
     "Weapon 1 Concealment",
     "Weapon 1 Reload",
     "Weapon 2 Name",
     "Weapon 2 Damage",
     "Weapon 2 Concealment",
     "Weapon 2 Reload",
     "Weapon 3 Name",
     "Weapon 3 Damage",
     "Weapon 3 Concealment",
     "Weapon 3 Reload",
     "Weapon 4 Name",
     "Weapon 4 Damage",
     "Weapon 4 Concealment",
     "Weapon 4 Reload",
     "Weapon 5 Name",
     "Weapon 5 Damage",
     "Weapon 5 Concealment",
     "Weapon 5 Reload",
     "Gear",
     "Skills",
     "Archetype",
     "Quote",
     "Juncture",
     "Wealth",
     "Story",
     "Melodramatic Hook",
     "Important GMCs",
     "Credits"
   ]

  class << self
    def pdf_to_character(uploaded_file, campaign, params={})
      temp_file_path = Tempfile.new('uploaded_pdf').path
      File.open(temp_file_path, 'wb') do |file|
        file.write(uploaded_file.read)
      end

      fields = pdftk.get_fields(temp_file_path.to_s)
      if fields.find { |f| f.name == "Name" }
        character_params = params.merge(pdf_attributes_for_character(fields, campaign))
      else
        raise "Invalid PDF: Missing required fields"
      end

      @character = campaign.characters.new(character_params)
    end

    def character_to_pdf(character)
      fields = self.character_attributes_for_pdf(character)
      fill_fields(fields)
    end

    def fill_fields(params={})
      path = Rails.root.join('public', 'pdfs', 'character_sheet.pdf')
      temp_path = Tempfile.new('filled.pdf').path
      pdftk.fill_form(path, temp_path, params, flatten: false)

      temp_path
    end

    def pdf_attributes_for_character(fields, campaign)
      {
        name: fields.find { |f| f.name == "Name" }&.value.presence || fields.find { |f| f.name == "Archetype" }&.value.presence || "Unnamed Character",
        action_values: action_values_from_pdf(fields),
        wealth: get_field(fields, "Wealth"),
        skills: get_skills_from_pdf(fields),
        description: get_description_from_pdf(fields),
        juncture: get_juncture(fields, campaign),
        weapons: get_weapons_from_pdf(fields, campaign),
        schticks: get_schticks_from_pdf(fields, campaign),
      }
    end

    def get_description_from_pdf(fields)
      {
        "Melodramatic Hook" => get_field(fields, "Melodramatic Hook"),
        "Background" => get_field(fields, "Story"),
      }
    end

    def get_weapons_from_pdf(fields, campaign)
      (1..5).reduce([]) do |weapons, index|
        weapon = get_weapon(fields, index, campaign)
        weapons << weapon if weapon
        weapons
      end
    end

    def get_weapon(fields, index, campaign)
      name = get_field(fields, "Weapon #{index} Name")
      return nil if name.blank?
      damage = get_field(fields, "Weapon #{index} Damage")
      concealment = get_field(fields, "Weapon #{index} Concealment")
      reload_value = get_field(fields, "Weapon #{index} Reload")

      weapon = campaign.weapons.find_or_create_by(name: name) do |w|
        w.damage = damage.to_i
        w.concealment = concealment
        w.reload_value = reload_value
        w.description = ""
        w.kachunk = ""
        w.juncture = ""
      end
    end

    def get_schtick(fields, index, campaign)
      name = get_field(fields, "Schtick #{index} Title")
      return nil if name.blank?
      description = get_field(fields, "Schtick #{index} Text")
      campaign.schticks.find_by(name: name)
    end

    def get_schticks_from_pdf(fields, campaign)
      (1..10).reduce([]) do |schticks, index|
        schtick = get_schtick(fields, index, campaign)
        if schtick
          schticks << schtick
        end
        schticks
      end
    end

    def get_juncture(fields, campaign)
      name = get_field(fields, "Juncture")
      return nil if name.blank?
      juncture = campaign.junctures.find_by(name: name)
      if juncture.nil?
        Rails.logger.error("Juncture not found: #{name}")
        return nil
      end
      juncture
    end

    def get_secondary_attack_from_pdf(fields)
      get_field(fields, "Skills")
        .to_s
        .split("\r")
        .map { |skill| skill.split(":") }
        .filter { |skill| skill.length == 2 && skill[0].strip == "Backup Attack" }
        .map { |skill| match = skill[1].match(/\s*(.*?)\s*\((\d+)\)/) }
        .map { |match| match ? { "SecondaryAttack" => match[1], match[1] => match[2].to_i } : nil }
        .first
    end

    def get_skills_from_pdf(fields)
      skills_text = get_field(fields, "Skills")
      skills = skills_text.to_s.split("\r").map do |skill|
        match = skill.match(/^(.+?)\s+(\d+)$/)
        match ? [match[1].strip, match[2].strip] : nil
      end.compact
      skills.reduce({}) do |att, skill|
        name = skill[0]
        value = skill[1]

        if name != "Backup Attack"
          att[name] = value.to_i
        end

        att
      end
    end

    def action_values_from_pdf(fields)
      {
        "MainAttack" => get_field(fields, "Attack Type"),
        get_field(fields, "Attack Type") => get_field(fields, "Attack"),
        "Defense" => get_field(fields, "Defense"),
        "Toughness" => get_field(fields, "Toughness"),
        "FortuneType" => get_field(fields, "Fortune Type"),
        "Max Fortune" => get_field(fields, "Fortune"),
        "Fortune" => get_field(fields, "Fortune"),
        "Speed" => get_field(fields, "Speed"),
        "SecondaryAttack" => nil,
        "Type" => "PC",
        "Archetype" => get_field(fields, "Archetype"),
      }.merge(get_secondary_attack_from_pdf(fields) || {})
    end

    def get_field(fields, name)
      fields.find { |f| f.name == name }&.value
    end

    def character_attributes_for_pdf(character)
      main_attack = character.action_values["MainAttack"]
      secondary_attack = character.action_values["SecondaryAttack"]

      schticks = character.schticks.limit(10)
      weapons = character.weapons.limit(4)
      skills = character.skills.filter { |name, value| value > 0 }.map { |name, value| "#{name}: #{value}" }.join("\n")
      if secondary_attack.present?
        backup_attack = "Backup Attack: #{secondary_attack} (#{character.action_values[secondary_attack]})"
        skills = "#{backup_attack}\n#{skills}"
      end

      {
        "Name" => character.name,
        "Attack Type" => main_attack,
        "Attack" => character.action_values[main_attack],
        "Defense" => character.action_values["Defense"],
        "Toughness" => character.action_values["Toughness"],
        "Fortune Type" => character.action_values["Fortune Type"],
        "Fortune" => character.action_values["Max Fortune"],
        "Speed" => character.action_values["Speed"],
        "Schtick 1 Title" => FightPoster.strip_html_p_to_br(schticks[0]&.name),
        "Schtick 1 Text" => "\n" + FightPoster.strip_html_p_to_br(schticks[0]&.description),
        "Schtick 2 Title" => FightPoster.strip_html_p_to_br(schticks[1]&.name),
        "Schtick 2 Text" => "\n" + FightPoster.strip_html_p_to_br(schticks[1]&.description),
        "Schtick 3 Title" => FightPoster.strip_html_p_to_br(schticks[2]&.name),
        "Schtick 3 Text" => "\n" + FightPoster.strip_html_p_to_br(schticks[2]&.description),
        "Schtick 4 Title" => FightPoster.strip_html_p_to_br(schticks[3]&.name),
        "Schtick 4 Text" => "\n" + FightPoster.strip_html_p_to_br(schticks[3]&.description),
        "Schtick 5 Title" => FightPoster.strip_html_p_to_br(schticks[4]&.name),
        "Schtick 5 Text" => "\n" + FightPoster.strip_html_p_to_br(schticks[4]&.description),
        "Schtick 6 Title" => FightPoster.strip_html_p_to_br(schticks[5]&.name),
        "Schtick 6 Text" => "\n" + FightPoster.strip_html_p_to_br(schticks[5]&.description),
        "Schtick 7 Title" => FightPoster.strip_html_p_to_br(schticks[6]&.name),
        "Schtick 7 Text" => "\n" + FightPoster.strip_html_p_to_br(schticks[6]&.description),
        "Schtick 8 Title" => FightPoster.strip_html_p_to_br(schticks[7]&.name),
        "Schtick 8 Text" => "\n" + FightPoster.strip_html_p_to_br(schticks[7]&.description),
        "Schtick 9 Title" => FightPoster.strip_html_p_to_br(schticks[8]&.name),
        "Schtick 9 Text" => "\n" + FightPoster.strip_html_p_to_br(schticks[8]&.description),
        "Schtick 10 Title" => FightPoster.strip_html_p_to_br(schticks[9]&.name),
        "Schtick 10 Text" => "\n" + FightPoster.strip_html_p_to_br(schticks[9]&.description),
        "Weapon 1 Name" => "Unarmed",
        "Weapon 1 Damage" => 7,
        "Weapon 1 Concealment" => "",
        "Weapon 1 Reload" => "",
        "Weapon 2 Name" => FightPoster.strip_html_p_to_br(weapons[0]&.name),
        "Weapon 2 Damage" => weapons[0]&.damage,
        "Weapon 2 Concealment" => weapons[0]&.concealment,
        "Weapon 2 Reload" => weapons[0]&.reload_value,
        "Weapon 3 Name" => FightPoster.strip_html_p_to_br(weapons[1]&.name),
        "Weapon 3 Damage" => weapons[1]&.damage,
        "Weapon 3 Concealment" => weapons[1]&.concealment,
        "Weapon 3 Reload" => weapons[1]&.reload_value,
        "Weapon 4 Name" => FightPoster.strip_html_p_to_br(weapons[2]&.name),
        "Weapon 4 Damage" => weapons[2]&.damage,
        "Weapon 4 Concealment" => weapons[2]&.concealment,
        "Weapon 4 Reload" => weapons[2]&.reload_value,
        "Weapon 5 Name" => FightPoster.strip_html_p_to_br(weapons[3]&.name),
        "Weapon 5 Damage" => weapons[3]&.damage,
        "Weapon 5 Concealment" => weapons[3]&.concealment,
        "Weapon 5 Reload" => weapons[3]&.reload_value,
        "Gear" => "",
        "Skills" => "\n#{skills}",
        "Archetype" => character.action_values["Archetype"],
        "Quote" => "",
        "Juncture" => "",
        "Wealth" => "",
        "Story" => FightPoster.strip_html_p_to_br(character.description["Background"]),
        "Melodramatic Hook" => FightPoster.strip_html_p_to_br(character.description["Melodramatic Hook"]),
        "Important GMCs" => "",
      }
    rescue StandardError => e
    end

    def pdftk
      if Rails.env.production?
        @pdftk ||= PdfForms.new("/usr/bin/pdftk")
      else
        @pdftk ||= PdfForms.new
      end
    end
  end
end
