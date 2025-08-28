class WeaponDeletionService < EntityDeletionService
  protected

  def association_counts(weapon)
    {
      'characters' => {
        count: weapon.character_weapons.count,
        label: 'characters carrying'
      },
      'vehicles' => {
        count: weapon.vehicle_weapons.count,
        label: 'vehicles mounted'
      }
    }
  end

  def handle_associations(weapon)
    # Remove weapon from all characters
    weapon.character_weapons.destroy_all
    
    # Remove weapon from all vehicles
    weapon.vehicle_weapons.destroy_all
  end

  def entity_type_name
    'weapon'
  end
end