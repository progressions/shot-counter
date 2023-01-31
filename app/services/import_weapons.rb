module ImportWeapons
  class << self
    def call(data, campaign)
      data.each do |juncture|
        parse_juncture(juncture, campaign)
      end
    end

    def parse_juncture(juncture, campaign)
      juncture["categories"].each do |categories|
        parse_category(categories, juncture, campaign)
      end
    end

    def parse_category(category, juncture, campaign)
      category["weapons"].each do |attributes|
        parse_attributes(attributes, category, juncture, campaign)
      end
    end

    def parse_attributes(attributes, category, juncture, campaign)
      match = attributes["name"].match(/^(.*)\s(.+)\/(.+)\/(.+)$/)
      if (match.nil?)
        raise attributes.inspect
      end
      name = match[1]
      damage = number_or_nil(match[2])
      concealment = number_or_nil(match[3])
      reload_value = number_or_nil(match[4])

      weapon = campaign.weapons.find_by(juncture: juncture["name"].titleize, category: category["name"], name: attributes["name"]) || campaign.weapons.new

      weapon.juncture = juncture["name"].titleize
      weapon.category = category["name"].titleize
      weapon.name = attributes["name"]
      weapon.description = attributes["description"]
      weapon.mook_bonus = attributes["mook_bonus"].to_i
      weapon.kachunk = attributes["kachunk"]

      weapon.damage = damage
      weapon.concealment = concealment
      weapon.reload_value = reload_value

      weapon.save
    end

    def number_or_nil(value)
      return value.to_i if value.to_i > 0
      return nil
    end
  end
end
