class WeaponDeletionService < EntityDeletionService
  protected

  # Weapons with carries cannot be deleted (unless forced)
  def blocking_constraints(weapon)
    constraints = {}
    
    carries_count = weapon.carries.count
    if carries_count > 0
      constraints['carries'] = {
        count: carries_count,
        label: 'characters/vehicles carrying'
      }
    end
    
    constraints
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