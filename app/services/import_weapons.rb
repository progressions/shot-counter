module ImportWeapons
  class << self
    def call(data, campaign)
      data.each do |juncture|
        parse_juncture(juncture, campaign)
      end
    end

    def parse_juncture(juncture, campaign)
      juncture["weapons"].each do |attributes|
        parse_attributes(attributes, juncture, campaign)
      end
    end

    def parse_attributes(attributes, juncture, campaign)
      match = attributes["name"].match(/^(.*)\s(.+)\/(.+)\/(.+)$/)
      name = match[1]
      damage = number_or_nil(match[2])
      concealment = number_or_nil(match[3])
      reload_value = number_or_nil(match[4])

      weapon = campaign.weapons.find_by(juncture: juncture["name"].titleize, name: attributes["name"]) || campaign.weapons.new

      weapon.juncture = juncture["name"].titleize
      weapon.name = attributes["name"]
      weapon.description = attributes["description"]

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
