class VehicleDeletionService < EntityDeletionService
  protected

  def association_counts(vehicle)
    {
      'shots' => {
        count: vehicle.shots.count,
        label: 'active chase positions'
      },
      'memberships' => {
        count: vehicle.memberships.count,
        label: 'party memberships'
      }
    }
  end

  def handle_associations(vehicle)
    # Remove from active fights/chases
    vehicle.shots.destroy_all
    
    # Remove from party memberships
    vehicle.memberships.destroy_all
  end

  def entity_type_name
    'vehicle'
  end
end