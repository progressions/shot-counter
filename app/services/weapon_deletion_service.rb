class WeaponDeletionService < EntityDeletionService
  protected

  def association_counts(weapon)
    {
      'carries' => {
        count: weapon.carries.count,
        label: 'characters/vehicles carrying'
      }
    }
  end

  def handle_associations(weapon)
    # Remove all carry relationships (characters and vehicles carrying this weapon)
    weapon.carries.destroy_all
  end

  def entity_type_name
    'weapon'
  end
end