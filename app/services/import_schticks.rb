module ImportSchticks
  class << self

    ROMAN_NUMERALS = ["I", "II", "III", "IV", "V"]

    def call(data, campaign)
      data.each do |category|
        parse_category(category, campaign)
      end
    end

    def get_previous_numeral(numeral)
      if ROMAN_NUMERALS.include?(numeral.upcase)
        previous_index = ROMAN_NUMERALS.index(numeral.upcase) - 1
        if (previous_index >= 0)
          return ROMAN_NUMERALS[previous_index]
        end
      end
    end

    def find_prerequisite(attributes, campaign)
      prereq_title = nil

      numeral = attributes["title"].split(" ").last
      previous_numeral = get_previous_numeral(numeral)

      if previous_numeral
        prereq_title = attributes["title"].gsub(numeral, previous_numeral)
      end

      if attributes["prerequisite"]
        prereq_title = attributes["prerequisite"].gsub(".", "")
      end

      campaign.schticks.find_by(title: prereq_title)
    end

    def parse_category(category, campaign)
      category["paths"].each do |path|
        parse_path(path, category, campaign)
      end
    end

    def parse_path(path, category, campaign)
      path["schticks"].each do |attributes|
        parse_attributes(attributes, category, path, campaign)
      end
    end

    def parse_attributes(attributes, category, path, campaign)
      schtick = campaign.schticks.find_by(category: category["name"].titleize, title: attributes["title"]) || campaign.schticks.new

      schtick.category = category["name"].titleize
      schtick.title = attributes["title"]
      schtick.description = attributes["description"]
      schtick.bonus = attributes["bonus"]
      schtick.archetypes = category["archetypes"]

      if path["name"]
        schtick.path = path["name"].titleize
      end

      schtick.prerequisite = find_prerequisite(attributes, campaign)

      schtick.save
    end

  end
end
