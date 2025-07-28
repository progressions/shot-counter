class Schtick < ApplicationRecord
  CATEGORIES = [
    "Guns",
    "Martial Arts",
    "Driving",
    "Sorcery",
    "Creature",
    "Transformed Animal",
    "Gene Freak",
    "Cyborg",
    "Foe"
  ]

  COLORS = {
    "Guns" => "#b71c1c",
    "Martial Arts" => "#4a148c",
    "Driving"=> "#311b92",
    "Sorcery"=> "#0d47a1",
    "Creature"=> "#006064",
    "Transformed Animal"=> "#1b5e20",
    "Gene Freak"=> "#9e9d24",
    "Cyborg"=> "#ff8f00",
    "Foe" => "#bf360c",
    "Core" => "#3e2723"
  }

  belongs_to :campaign
  belongs_to :prerequisite, class_name: "Schtick", optional: true
  has_many :character_schticks
  has_many :characters, through: :character_schticks

  validates :name, presence: true, uniqueness: { scope: :category }
  validates :category, inclusion: { in: CATEGORIES }, allow_nil: true, unless: -> { path == "Core" }
  validate :prerequisite_must_be_in_same_category_and_path

  has_one_attached :image

  after_update :broadcast_campaign_update

  def self.for_archetype(archetype)
    where("schticks.archetypes @> ?", [archetype].flatten.to_json)
  end

  def as_v1_json(args={})
    {
      id: id,
      name: name,
      description: description,
      category: category,
      path: path,
      color: color,
      prerequisite: {
        id: prerequisite&.id,
        name: prerequisite&.name,
      },
      archetypes: archetypes
    }
  end

  def prerequisite_must_be_in_same_category_and_path
    return unless prerequisite
    return if prerequisite.category == category && prerequisite.path == path

    errors.add(:prerequisite, "must be in the same category and path")
  end

  # Scope to filter schticks to the highest Roman numeral for each base name
  scope :highest_numbered, -> {
    # Fetch all schticks with prerequisites in one query
    all_schticks = includes(:prerequisite).to_a

    # Group schticks by base name and select the highest Roman numeral
    grouped_schticks = all_schticks.group_by { |s| base_name(s.name) }
    highest_schticks = grouped_schticks.map do |base, schticks|
      schticks.max_by { |s| roman_to_int(roman_numeral(s.name)) }
    end

    # Return an ActiveRecord::Relation that includes only the selected schticks
    where(id: highest_schticks.map(&:id))
  }

  # Extract the base name by removing the Roman numeral suffix
  def self.base_name(name)
    name.sub(/\s+[IVXLCDM]+$/i, '').strip
  end

  # Extract the Roman numeral from the name
  def self.roman_numeral(name)
    match = name.match(/\s+([IVXLCDM]+)$/i)
    match ? match[1].upcase : ''
  end

  # Convert Roman numeral to integer
  def self.roman_to_int(roman)
    return 0 if roman.empty?

    values = {
      'I' => 1,
      'V' => 5,
      'X' => 10,
      'L' => 50,
      'C' => 100,
      'D' => 500,
      'M' => 1000
    }

    result = 0
    prev_value = 0

    roman.upcase.reverse.each_char do |char|
      current_value = values[char] || 0
      if current_value >= prev_value
        result += current_value
      else
        result -= current_value
      end
      prev_value = current_value
    end

    result
  end

  def image_url
    image.attached? ? image.url : nil
  end

  private

  def broadcast_campaign_update
    channel = "campaign_#{campaign_id}"
    payload = { schtick: SchtickSerializer.new(self).as_json }
    ActionCable.server.broadcast(channel, payload)
  rescue StandardError => e
    Rails.logger.error "Failed to broadcast campaign update for juncture #{id}: #{e.message}"
  end
end
