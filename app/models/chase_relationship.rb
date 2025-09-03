class ChaseRelationship < ApplicationRecord
  # Associations
  belongs_to :pursuer, class_name: 'Vehicle', foreign_key: 'pursuer_id'
  belongs_to :evader, class_name: 'Vehicle', foreign_key: 'evader_id'
  belongs_to :fight

  # Validations
  validates :position, presence: true, inclusion: { in: ['near', 'far'] }
  validate :different_vehicles_validation
  validate :unique_active_relationship_validation

  # Scopes
  scope :active, -> { where(active: true) }
  scope :for_fight, ->(fight) { where(fight: fight) }
  scope :for_vehicle, ->(vehicle_id) { where('pursuer_id = ? OR evader_id = ?', vehicle_id, vehicle_id) }

  # Instance methods
  def near?
    position == 'near'
  end

  def far?
    position == 'far'
  end

  private

  def different_vehicles_validation
    if pursuer_id == evader_id
      errors.add(:evader_id, "can't be the same as pursuer")
    end
  end

  def unique_active_relationship_validation
    return unless active?
    
    existing = ChaseRelationship
      .where(pursuer_id: pursuer_id, evader_id: evader_id, fight_id: fight_id, active: true)
      .where.not(id: id)
    
    if existing.exists?
      errors.add(:pursuer_id, 'already has an active relationship with this evader in this fight')
    end
  end
end