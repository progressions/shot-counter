class FactionDeletionService < EntityDeletionService
  protected

  def association_counts(faction)
    {
      'characters' => {
        count: faction.characters.count,
        label: 'faction members'
      }
    }
  end

  def handle_associations(faction)
    # Remove faction association from characters
    faction.characters.update_all(faction_id: nil)
  end

  def entity_type_name
    'faction'
  end
end