require "pdf_forms"

module PdfService
   FIELDS = [
     "Name",
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

    def character_attributes_for_pdf(character)
      main_attack = character.action_values["MainAttack"]
      schticks = character.schticks.limit(10)
      weapons = character.weapons.limit(5)
      skills = character.skills.filter { |name, value| value > 0 }.map { |name, value| "#{name}: #{value}" }.join("\n")
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
        "Weapon 1 Name" => FightPoster.strip_html_p_to_br(weapons[0]&.name),
        "Weapon 1 Damage" => weapons[0]&.damage,
        "Weapon 1 Concealment" => weapons[0]&.concealment,
        "Weapon 1 Reload" => weapons[0]&.reload_value,
        "Weapon 2 Name" => FightPoster.strip_html_p_to_br(weapons[1]&.name),
        "Weapon 2 Damage" => weapons[1]&.damage,
        "Weapon 2 Concealment" => weapons[1]&.concealment,
        "Weapon 2 Reload" => weapons[1]&.reload_value,
        "Weapon 3 Name" => FightPoster.strip_html_p_to_br(weapons[2]&.name),
        "Weapon 3 Damage" => weapons[2]&.damage,
        "Weapon 3 Concealment" => weapons[2]&.concealment,
        "Weapon 3 Reload" => weapons[2]&.reload_value,
        "Weapon 4 Name" => FightPoster.strip_html_p_to_br(weapons[3]&.name),
        "Weapon 4 Damage" => weapons[3]&.damage,
        "Weapon 4 Concealment" => weapons[3]&.concealment,
        "Weapon 4 Reload" => weapons[3]&.reload_value,
        "Weapon 5 Name" => FightPoster.strip_html_p_to_br(weapons[4]&.name),
        "Weapon 5 Damage" => weapons[4]&.damage,
        "Weapon 5 Concealment" => weapons[4]&.concealment,
        "Weapon 5 Reload" => weapons[4]&.reload_value,
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
    end

    def pdftk
      @pdftk ||= PdfForms.new
    end
  end
end
