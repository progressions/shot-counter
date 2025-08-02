# app/services/grok_service.rb
class GrokService
  include HTTParty

  base_uri 'https://api.x.ai'

  MAX_PROMPT_LENGTH = 1024

  def initialize
    @api_key = Rails.application.credentials.grok.api_key || ENV['GROK_API_KEY']
    @headers = {
      'Authorization' => "Bearer #{@api_key}",
      'Content-Type' => 'application/json'
    }
  end

  def send_request(prompt, max_tokens=2048)
    payload = {
      model: 'grok-4',
      messages: [{ role: 'user', content: prompt }],
      max_tokens: max_tokens
    }
    response = self.class.post('/v1/chat/completions', headers: @headers, body: payload.to_json)
    handle_response(response)
  end

  def generate_image(prompt, num_images=3, response_format='url')
    truncated_prompt = prompt.to_s[0...MAX_PROMPT_LENGTH]
    if prompt.length > MAX_PROMPT_LENGTH
      Rails.logger.warn("Prompt truncated to #{MAX_PROMPT_LENGTH} characters for image generation: #{truncated_prompt}")
    end

    payload = {
      model: 'grok-2-image-1212',
      prompt: truncated_prompt,
      n: num_images.clamp(1, 10),
      response_format: response_format
    }
    response = self.class.post('/v1/images/generations', headers: @headers, body: payload.to_json)
    parsed_response = handle_response(response)

    image_data = parsed_response['data']&.map do |item|
      case response_format
      when 'b64_json'
        b64_data = item['b64_json'] || raise("No base64 data in response: #{parsed_response}")
        "data:image/jpeg;base64,#{b64_data}"
      when 'url'
        item['url'] || raise("No image URL in response: #{parsed_response}")
      else
        raise "Unsupported response format: #{response_format}"
      end
    end || []
    if image_data.empty?
      raise "No image data found in response: #{parsed_response}"
    end
    num_images == 1 ? image_data.first : image_data
  end

  private

  def handle_response(response)
    if response.success?
      JSON.parse(response.body)
    else
      raise "Request failed with status #{response.code}: #{response.body}"
    end
  end
end
