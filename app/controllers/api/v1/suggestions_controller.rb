class Api::V1::SuggestionsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign

  # Define searchable models and their attributes
  SEARCHABLE_MODELS = [
    { klass: Character, table: "characters", attributes: [:name] },
    { klass: Vehicle, table: "vehicles", attributes: [:name] }
  ].freeze

  def index
    query = params[:query]&.downcase&.strip
    # Return empty array for blank or empty queries
    return render json: [] if query.blank?

    results = fetch_suggestions(query)

    # Format results consistently across models
    suggestions_json = results.map do |record|
      {
        className: record.class.name,
        id: record.id,
        label: record.name
      }
    end

    render json: suggestions_json
  end

  private

  def fetch_suggestions(query)
    sanitized_query = ActiveRecord::Base.sanitize_sql_like(query)
    sanitized_campaign_id = ActiveRecord::Base.connection.quote_string(current_campaign.id)

    # Build UNION query for all searchable models
    union_queries = SEARCHABLE_MODELS.map do |model|
      table = model[:table]
      Arel.sql(
        "SELECT id, name, '#{model[:klass].name}' as class_name
         FROM #{table}
         WHERE campaign_id = '#{sanitized_campaign_id}'
         AND lower(name) LIKE '%#{sanitized_query}%'"
      )
    end

    # Combine queries with LIMIT applied to the entire result
    union_sql = "(#{union_queries.join(' UNION ')}) LIMIT 10"
    results = ActiveRecord::Base.connection.execute(union_sql)

    # Map raw results to model instances
    results.group_by { |r| r["class_name"] }.flat_map do |class_name, records|
      klass = class_name.constantize
      ids = records.map { |r| r["id"] }
      # Fetch records in one query per model
      klass.where(id: ids).select(:id, :name).to_a
    end.sort_by(&:name)
  end
end
