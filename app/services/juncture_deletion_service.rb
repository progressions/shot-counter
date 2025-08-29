class JunctureDeletionService < EntityDeletionService
  protected

  def association_counts(juncture)
    {
      'characters' => {
        count: juncture.characters.count,
        label: 'juncture characters'
      },
      'vehicles' => {
        count: juncture.vehicles.count,
        label: 'juncture vehicles'
      }
    }
  end

  def handle_associations(juncture)
    # Remove juncture association from characters
    juncture.characters.update_all(juncture_id: nil)
    # Remove juncture association from vehicles  
    juncture.vehicles.update_all(juncture_id: nil)
  end

  def entity_type_name
    'juncture'
  end
end