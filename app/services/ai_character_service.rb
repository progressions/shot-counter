class AiCharacterService
  class << self
    def generate_character(description)
      prompt = <<~PROMPT
        You are a creative AI character generator for a game of Feng Shui 2, the action movie roleplaying game.
        Based on the following description, create a detailed character profile:

        The character is a villain--not necessarily pure evil, but definitely an antagonist to the heroes.
        Determine if the villain is a Mook, Featured Foe, or Boss based on the description. Don't include the
        type in the description itself, but use it to determine the attributes. A Featured Foe is a significant
        antagonist with unique abilities and a backstory, while a Boss is a major villain with powerful abilities.

        If the character is a Mook, they should be a generic henchman with basic attributes.

        Description: #{description}

        Include these attributes for the character:
        - Name
        - Description
        - Type: Mook, Featured Foe, or Boss
        - Main Attack: Either Guns, Sorcery, Martial Arts, Scroungetech (cyborg enhancements), or Creature (for supernatural creatures like werewolves or monsters)
        - Attack Value: A number between 13 and 16. A Mook has the attack value of 9.
        - Defense: A number between 13 and 16. A Mook has the defense value of 13.
        - Toughness: A number between 5 and 8.
        - Speed: A number between 5 and 8. A Mook has the speed of 6.

        Respond with a JSON object describing the character, including all attributes.
      PROMPT

      response = grok.send_request(prompt)

      if response['choices'] && response['choices'].any?
        json = response['choices'].first['message']['content']

        begin
          JSON.parse(json)
        rescue JSON::ParserError => e
          Rails.logger.error("JSON parsing error: #{e.message} for response: #{json}")

          json
        end
      else
        raise "Unexpected response format: #{response}"
      end
    rescue StandardError => e
      puts response.inspect if defined?(response)
      Rails.logger.error("Error generating character: #{e.message}")
      raise e
    end

    def grok
      @grok ||= GrokService.new
    end
  end
end
