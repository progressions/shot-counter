class GrokService
  include HTTParty
  base_uri 'https://api.x.ai'

  def initialize
    @api_key = Rails.application.credentials.grok.api_key || ENV['GROK_API_KEY']
    @headers = {
      'Authorization' => "Bearer #{@api_key}",
      'Content-Type' => 'application/json'
    }
  end

  def send_request(prompt)
    payload = {
      model: 'grok-4', # Specify the model (e.g., grok-4)
      messages: [{ role: 'user', content: prompt }],
      max_tokens: 1000
    }

    response = self.class.post('/v1/chat/completions', headers: @headers, body: payload.to_json)
    handle_response(response)
  end

  private

  def handle_response(response)
    if response.success?
      JSON.parse(response.body)
    else
      raise "API request failed with status #{response.code}: #{response.message}"
    end
  end
end
