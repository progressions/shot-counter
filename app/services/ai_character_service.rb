# app/services/ai_character_service.rb
class AiCharacterService
  class << self
    include Rails.application.routes.url_helpers

    MAX_PROMPT_LENGTH = 1024

    def generate_character(description, campaign)
      prompt = build_prompt(description, campaign)
      max_retries = 3
      retry_count = 0
      max_tokens = 1000

      begin
        response = grok.send_request(prompt, max_tokens)
        if response['choices'] && response['choices'].any?
          choice = response.dig("choices", 0)
          content = choice.dig("message", "content")
          finish_reason = choice['finish_reason']
          if content.blank? || finish_reason == 'length'
            raise "Incomplete response: content empty or truncated due to length"
          end
          json = JSON.parse(content)
          return json if valid_json?(json)
          raise "Invalid JSON structure"
        else
          raise "Unexpected response format: #{response}"
        end
      rescue JSON::ParserError, StandardError => e
        Rails.logger.error("Error generating character: #{e.message}. Response: #{response.inspect if defined?(response)}")
        retry_count += 1
        if retry_count <= max_retries
          max_tokens += 1024
          Rails.logger.info("Retrying (#{retry_count}/#{max_retries}) with increased max_tokens: #{max_tokens}")
          retry
        else
          raise "Failed after #{max_retries} retries: #{e.message}"
        end
      end
    end

    def generate_character_image(character)
      raise 'Character must be provided' unless character
      raise 'Character must respond to action_values and description' unless character.respond_to?(:action_values) && character.respond_to?(:description)
      raise 'Character must be saved before attaching image' if character.new_record?
      raise "Character is invalid: #{character.errors.full_messages.join(', ')}" unless character.valid?

      prompt = build_image_prompt(character)
      max_retries = 3
      retry_count = 0

      begin
        image_url = grok.generate_image(prompt, num_images=1, response_format='url')
        Rails.logger.info("Generated image URL: #{image_url}")

        # Attach image to Character
        if character.respond_to?(:image)
          require 'open-uri'
          require 'tempfile'
          require 'mini_magick'

          filename = "character_image_#{character.id}.jpeg"
          Tempfile.create(['character_image', '.jpeg'], binmode: true) do |tempfile|
            begin
              URI.open(image_url) { |f| tempfile.write(f.read) }
              tempfile.flush
              tempfile.rewind
            rescue OpenURI::HTTPError => e
              raise "Failed to download image from #{image_url}: #{e.message}"
            end

            # Validate image data
            begin
              MiniMagick::Image.open(tempfile.path)
            rescue MiniMagick::Error => e
              raise "Invalid image data: #{e.message}"
            end

            ActiveRecord::Base.transaction do
              character.image.attach(
                io: File.open(tempfile.path),
                filename: filename,
                content_type: 'image/jpeg'
              )
              unless character.image.attached?
                raise "Failed to attach image to character ID: #{character.id}"
              end
              character.image.blob.save!
            end
            Rails.logger.info("Attached image to character ID: #{character.id}")
          end
        else
          Rails.logger.warn("Character does not have image attachment capability")
        end

        # Return Active Storage URL for client download
        character.image.attached? ? url_for(character.image) : image_url
      rescue StandardError => e
        Rails.logger.error("Error generating character image: #{e.message}\n#{e.backtrace.join("\n")}")
        retry_count += 1
        if retry_count <= max_retries && !e.message.match?(/Failed to download image|Invalid image data|Failed to attach image/)
          Rails.logger.info("Retrying image generation (#{retry_count}/#{max_retries})")
          retry
        else
          raise "Failed to generate image after #{max_retries} retries: #{e.message}"
        end
      end
    end

    def valid_json?(json)
      required_keys = %w[name description type mainAttack attackValue defense toughness speed damage faction juncture nicknames age height weight hairColor eyeColor styleOfDress wealth appearance]
      required_keys.all? { |key| json.key?(key) }
    end

    def build_image_prompt(character)
      description = <<~DESCRIPTION
        Archetype: #{character.action_values["Archetype"] || 'Unknown'}
        Description: #{character.description["Appearance"] || 'A stylish character'}
        Background: #{character.description["Background"] || 'An action-ready antagonist'}
      DESCRIPTION

      if description.length > 700
        Rails.logger.warn("Character description truncated to 700 characters")
        description = description[0...700]
      end

      prompt = <<~PROMPT
        You are a creative AI image generator for a game of Feng Shui 2, the action movie roleplaying game.
        Based on this description, create an image of the character.
        Character: #{description}
        The character should look cool and ready for action. Show their weapons, based on the Archetype.
      PROMPT

      if prompt.length > MAX_PROMPT_LENGTH
        Rails.logger.warn("Image prompt truncated from #{prompt.length} to #{MAX_PROMPT_LENGTH} characters")
        prompt = prompt[0...MAX_PROMPT_LENGTH]
      end
      prompt
    end

    def build_prompt(description, campaign)
      <<~PROMPT
        You are a creative AI character generator for a game of Feng Shui 2, the action movie roleplaying game.
        Based on the following description, create a detailed character profile:
        The character is a villain--not necessarily pure evil, but definitely an antagonist to the heroes.
        Determine if the villain is a Mook, Featured Foe, or Boss based on the description. Don't include the
        type in the description itself, but use it to determine the attributes. A Featured Foe is a significant
        antagonist with unique abilities and a backstory, while a Boss is a major villain with powerful abilities.
        If the character is a Mook, they should be a generic henchman with basic attributes. Never give
        Mooks unique names or detailed descriptions. If the character is a Featured Foe or Boss, provide a
        unique name and a detailed description of their personality, motivations, and background.
        Description: #{description}
        Include these attributes for the character:
        - Name
        - Description
        - Type: Mook, Featured Foe, or Boss
        - Main Attack: Either Guns, Sorcery, Martial Arts, Scroungetech, Genome, or Creature
        - Attack Value: A number between 13 and 16. A Mook has the attack value of 9. A Boss has an attack value of between 17 and 20.
        - Defense: A number between 13 and 16. A Mook has the defense value of 13. A Boss has a defense of between 17 and 20.
        - Toughness: A number between 5 and 8. A Mook has a null value. A Boss has a defense of between 8 and 10.
        - Speed: A number between 5 and 8. A Mook has the speed of 6. A Boss has a speed of between 6 and 9.
        - Damage: A number between 7 and 12. A Mook has a damage value of 7.
        - Faction: The name of the faction the character belongs to, if not specified in the description. Use one of the following factions from the campaign: #{faction_names(campaign)}.
        - Juncture: The name of the temporal juncture where the character originated, if not specified in the description. Use one of the following juntures: #{juncture_names(campaign)}.
        - Nicknames: A comma-separated string
        - Age
        - Height (in feet and inches)
        - Weight (in pounds)
        - Hair Color
        - Eye Color
        - Style of Dress: A brief description of their clothing style
        - Wealth: Poor, Working Stiff, or Rich
        - Appearance: A short paragraph describing their physical appearance
        Respond with a JSON object describing the character, including all attributes. Use lowercase camelCase for keys.
      PROMPT
    end

    def juncture_names(campaign)
      campaign.junctures.pluck(:name).join(', ')
    end

    def faction_names(campaign)
      campaign.factions.pluck(:name).join(', ')
    end

    def grok
      @grok ||= GrokService.new
    end
  end
end
