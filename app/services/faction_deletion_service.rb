class FactionDeletionService < EntityDeletionService
  protected

  def association_counts(faction)
    {
      'characters' => {
        count: faction.characters.count,
        label: 'faction members'
      },
      'vehicles' => {
        count: faction.vehicles.count,
        label: 'faction vehicles'
      },
      'junctures' => {
        count: faction.junctures.count,
        label: 'faction junctures'
      },
      'parties' => {
        count: faction.parties.count,
        label: 'faction parties'
      },
      'sites' => {
        count: faction.sites.count,
        label: 'faction sites'
      }
    }
  end

  def handle_associations(faction)
    # Remove faction association from characters
    faction.characters.update_all(faction_id: nil)
    # Remove faction association from vehicles
    faction.vehicles.update_all(faction_id: nil)
    # Remove faction association from junctures
    faction.junctures.update_all(faction_id: nil)
    # Remove faction association from parties
    faction.parties.update_all(faction_id: nil)
    # Remove faction association from sites
    faction.sites.update_all(faction_id: nil)
  end

  def entity_type_name
    'faction'
  end
end