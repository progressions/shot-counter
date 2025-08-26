class Api::V1::SuggestionsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign

  # Define searchable models and their attributes
  SEARCHABLE_MODELS = [
    { klass: Character, table: "characters", attributes: [:name], visibility_filter: { column: "active", value: true } },
    { klass: Vehicle, table: "vehicles", attributes: [:name], visibility_filter: { column: "active", value: true } },
    { klass: Site, table: "sites", attributes: [:name], visibility_filter: { column: "active", value: true } },
    { klass: Party, table: "parties", attributes: [:name], visibility_filter: { column: "active", value: true } },
    { klass: Faction, table: "factions", attributes: [:name], visiblity_filter: nil },
    { klass: Schtick, table: "schticks", attributes: [:name], visiblity_filter: nil },
    { klass: Weapon, table: "weapons", attributes: [:name], visiblity_filter: nil },
    { klass: Juncture, table: "junctures", attributes: [:name], visiblity_filter: nil },
  ].freeze

  def index
    query = params[:query]&.downcase&.strip
    # Return empty hash for blank or empty queries
    return render json: {} if query.blank?

    results = fetch_suggestions(query)

    # Group results by class name and format consistently
    suggestions_json = results.group_by { |record| record.class.name }.transform_values do |records|
      records.map do |record|
        {
          className: record.class.name,
          id: record.id,
          label: record.name
        }
      end
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
      # Skip if table doesn't exist
      next unless ActiveRecord::Base.connection.table_exists?(table)

      filter = model[:visibility_filter]
      visibility_clause = filter ? "AND #{filter[:column]} = #{filter[:value]}" : ""
      Arel.sql(
        "SELECT id, name, '#{model[:klass].name}' as class_name
         FROM #{table}
         WHERE campaign_id = '#{sanitized_campaign_id}'
         AND lower(name) LIKE '%#{sanitized_query}%'
         #{visibility_clause}"
      )
    end.compact

    # Return empty array if no valid queries
    return [] if union_queries.empty?

    # Combine queries with LIMIT applied to the entire result
    union_sql = "(#{union_queries.join(' UNION ')}) LIMIT 10"
    Rails.logger.debug "Executing SQL: #{union_sql}"

    # Execute query and log raw results
    results = ActiveRecord::Base.connection.execute(union_sql).to_a
    Rails.logger.debug "Raw results: #{results.inspect}"

    # Map raw results to model instances
    results.group_by { |r| r["class_name"] }.flat_map do |class_name, records|
      Rails.logger.debug "Processing class: #{class_name}, records: #{records.inspect}"
      klass = class_name.constantize
      ids = records.map { |r| r["id"] }
      # Fetch records in one query per model
      klass.where(id: ids).select(:id, :name).to_a
    end.sort_by(&:name)
  end
end
