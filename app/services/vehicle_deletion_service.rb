class VehicleDeletionService < EntityDeletionService
  protected

  def association_counts(vehicle)
    {
      'weapons' => {
        count: vehicle.vehicle_weapons.count,
        label: 'weapons mounted'
      },
      'shots' => {
        count: vehicle.shots.count,
        label: 'active chase positions'
      }
    }
  end

  def handle_associations(vehicle)
    # Remove vehicle from weapons (clear carries relationship)
    vehicle.vehicle_weapons.destroy_all
    
    # Remove from active fights/chases
    vehicle.shots.destroy_all
  end

  def entity_type_name
    'vehicle'
  end
end