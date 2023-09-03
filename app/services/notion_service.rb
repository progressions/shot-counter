require 'open-uri'

module NotionService
  class << self

    def create_characters_from_notion(type: "PC")
      campaign = Campaign.find_by(name: "Born to Revengeance")
      response = find_pages_by_enemy_type(type)
      response.results.each do |page|
        find_or_create_character_from_notion(page, campaign: campaign)
      end
    end

    def find_pages_by_enemy_type(tag)
      database_id = "f6fa27ac-19cd-4b17-b218-55acc6d077be"
      filter = {
        and: [
          {
            property: "Enemy Type",
            select: {
              equals: tag
            }
          }
        ]
      }
      client.database_query(database_id: database_id, filter: filter)
    end

    def find_character(character)
      find_page_by_name(character.name)
    end

    def find_page_by_name(name)
      response = client.search(query: name, filter: { property: 'object', value: 'page' })
      if response["results"].length == 1
        response["results"]
      else
        response["results"]
      end
    end

    def add_faction(page, character)
      faction_id = page.properties.dig("Faction", "relation", 0, "id")
      return unless faction_id.present?

      faction = client.page(page_id: faction_id)
      faction_name = faction.dig("properties", "Name", "title")&.first&.dig("text", "content")
      character.faction = Faction.find_or_create_by(name: faction_name, campaign: character.campaign)
    rescue
    end

    def add_image(page, character)
      return if character.image.attached?

      response = client.block_children(block_id: page["id"])
      results = response["results"]
      image = results&.find { |block| block["type"] == "image" }

      return unless image.present?

      image_url = image.dig("image", "file", "url")
      if image_url.present?
        file = URI.open(image_url)
        character.image.attach(io: file, filename: "#{character.name.downcase.gsub(' ', '_')}.png")
      end
    rescue
    end

    def find_or_create_character_from_notion(page, campaign:)
      name = page.dig("properties", "Name", "title")&.first&.dig("plain_text")
      character = campaign.characters.find_or_create_by(name: name)
      character.save

      attributes = character.attributes_from_notion(page)
      character.notion_page_id = page["id"]
      character.update(attributes)

      add_faction(page, character)
      add_image(page, character)

      character.save
    end

    def get_page(page_id)
      client.page(page_id: page_id)
    end

    def update_character_from_notion(character)
      return unless character.notion_page_id.present?

      page = get_page(character.notion_page_id)
      attributes = character.attributes_from_notion(page)

      character.update(attributes)

      character.reload
    end

    def update_notion_from_character(character)
      return unless character.notion_page_id.present?

      properties = character.as_notion

      client.update_page(
        page_id: character.notion_page_id,
        properties: properties
      )
    end

    # private

    def client
      @client ||= Notion::Client.new
    end
  end
end
