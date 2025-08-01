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

  def send_request(prompt, max_tokens=2048)
    payload = {
      model: 'grok-4', # Specify the model (e.g., grok-4)
      messages: [{ role: 'user', content: prompt }],
      max_tokens: max_tokens
    }

    response = self.class.post('/v1/chat/completions', headers: @headers, body: payload.to_json)
    handle_response(response)
  end

  private

  def handle_response(response)
    if response.success?
      JSON.parse(response.body)
    end
  end
end
