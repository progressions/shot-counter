require 'open-uri'

module NotionService
  class << self
    DATABASE_ID = "f6fa27ac-19cd-4b17-b218-55acc6d077be"
    FACTIONS_DATABASE_ID = "0ae94bfa1a754c8fbda28ea50afa5fd5"

    def create_characters_from_notion(type: "PC")
      campaign = Campaign.find_by(name: "Born to Revengeance")
      response = find_pages_by_enemy_type(type)
      response.results.each do |page|
        find_or_create_character_from_notion(page, campaign: campaign)
      end
    end

    def find_pages_by_enemy_type(tag)
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
      client.database_query(database_id: DATABASE_ID, filter: filter)
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

    def find_faction_by_name(name)
      filter = { and: [{ property: "Name", rich_text: { equals: name } }] }
      response = client.database_query(database_id: FACTIONS_DATABASE_ID, filter: filter)

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

    def find_image_block(page)
      response = client.block_children(block_id: page["id"])
      results = response["results"]
      results&.find { |block| block["type"] == "image" }
    end

    def add_image(page, character)
      return if character.image.attached?

      image = find_image_block(page)

      return unless image.present?

      image_url = image.dig("image", "file", "url") || image.dig("image", "external", "url")
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

      description = get_description(page)
      character.description = description.merge(character.description.reject { |k, v| v.blank? })

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

    def create_notion_from_character(character)
      properties = character.as_notion

      if character.faction.present?
        properties["Faction"] = notion_faction_properties(character.faction.name)
      end

      page = client.create_page(
        parent: { database_id: "f6fa27ac-19cd-4b17-b218-55acc6d077be" },
        properties: properties
      )
      character.notion_page_id = page["id"]
      character.save

      add_image_to_notion(character)
    end

    def update_notion_from_character(character)
      return unless character.notion_page_id.present?

      properties = character.as_notion

      if character.faction.present?
        properties["Faction"] = notion_faction_properties(character.faction.name)
      end

      client.update_page(
        page_id: character.notion_page_id,
        properties: properties
      )

      image = find_image_block(get_page(character.notion_page_id))
      if !image.present?
        add_image_to_notion(character)
      end
    end

    def add_image_to_notion(character)
      return unless character.image_url.present?
      child = {"object" => "block", "type" => "image", "image" => { "type" => "external", "external" => { "url" => character.image_url } } }

      client.block_append_children(block_id: character.notion_page_id, children: [child])
    end

    def notion_faction_properties(name)
      faction = find_faction_by_name(name).first
      if faction.present?
        { "relation" => [{ "id" => faction["id"] }] }
      end
    end

    def get_description(page)
      children = client.block_children(block_id: page["id"])
      name_block = children.results.find { |p| p["type"] == "bulleted_list_item" && p.dig("bulleted_list_item", "rich_text", 0, "text", "content") =~ /Name: / }
      nicknames_block = children.results.find { |p| p["type"] == "bulleted_list_item" && p.dig("bulleted_list_item", "rich_text", 0, "text", "content") =~ /Nicknames: / }
      age_block = children.results.find { |p| p["type"] == "bulleted_list_item" && p.dig("bulleted_list_item", "rich_text", 0, "text", "content") =~ /Age: / }
      height_block = children.results.find { |p| p["type"] == "bulleted_list_item" && p.dig("bulleted_list_item", "rich_text", 0, "text", "content") =~ /Height: / }
      weight_block = children.results.find { |p| p["type"] == "bulleted_list_item" && p.dig("bulleted_list_item", "rich_text", 0, "text", "content") =~ /Weight: / }
      hair_color_block = children.results.find { |p| p["type"] == "bulleted_list_item" && p.dig("bulleted_list_item", "rich_text", 0, "text", "content") =~ /Hair color: / }
      eye_color_block = children.results.find { |p| p["type"] == "bulleted_list_item" && p.dig("bulleted_list_item", "rich_text", 0, "text", "content") =~ /Eye color: / }
      dress_block = children.results.find { |p| p["type"] == "bulleted_list_item" && p.dig("bulleted_list_item", "rich_text", 0, "text", "content") =~ /Dress: / }
      {
        "Age" => age_block&.dig("bulleted_list_item", "rich_text", 0, "text", "content")&.gsub("Age: ", ""),
        "Nicknames" => nicknames_block&.dig("bulleted_list_item", "rich_text", 0, "text", "content")&.gsub("Nicknames: ", ""),
        "Height" => height_block&.dig("bulleted_list_item", "rich_text", 0, "text", "content")&.gsub("Height: ", ""),
        "Weight" => weight_block&.dig("bulleted_list_item", "rich_text", 0, "text", "content")&.gsub("Weight: ", ""),
        "Hair Color" => hair_color_block&.dig("bulleted_list_item", "rich_text", 0, "text", "content")&.gsub("Hair color: ", ""),
        "Eye Color" => eye_color_block&.dig("bulleted_list_item", "rich_text", 0, "text", "content")&.gsub("Eye color: ", ""),
        "Style of Dress" => dress_block&.dig("bulleted_list_item", "rich_text", 0, "text", "content")&.gsub("Dress: ", ""),
      }
    end

    # private

    def client
      @client ||= Notion::Client.new
    end
  end
end
