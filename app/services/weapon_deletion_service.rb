class WeaponDeletionService < EntityDeletionService
  protected

  # No blocking constraints - weapons can always be deleted
  def blocking_constraints(weapon)
    {}
  end

  def association_counts(weapon)
    {
      'carries' => {
        count: weapon.carries.count,
        label: 'characters/vehicles carrying'
      }
    }
  end

  def cleanup_owned_associations(weapon)
    # Always clean up carry relationships when deleting weapon
    weapon.carries.destroy_all
  end

  # Legacy method for compatibility
  def handle_associations(weapon)
    cleanup_owned_associations(weapon)
  end

  def entity_type_name
    'weapon'
  end
end