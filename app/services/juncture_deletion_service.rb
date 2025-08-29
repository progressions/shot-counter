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
      },
      'sites' => {
        count: juncture.sites.count,
        label: 'juncture sites'
      },
      'parties' => {
        count: juncture.parties.count,
        label: 'juncture parties'
      }
    }
  end

  def handle_associations(juncture)
    # Remove juncture association from characters
    juncture.characters.update_all(juncture_id: nil)
    # Remove juncture association from vehicles  
    juncture.vehicles.update_all(juncture_id: nil)
    # Remove juncture association from sites
    juncture.sites.update_all(juncture_id: nil)
    # Remove juncture association from parties
    juncture.parties.update_all(juncture_id: nil)
  end

  def entity_type_name
    'juncture'
  end
end