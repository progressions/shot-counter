class CharacterDeletionService < EntityDeletionService
  protected

  def association_counts(character)
    {
      'schticks' => {
        count: character.schticks.count,
        label: 'schticks'
      },
      'weapons' => {
        count: character.carries.count,
        label: 'weapons carried'
      },
      'shots' => {
        count: character.shots.count,
        label: 'active fight positions'
      },
      'party_memberships' => {
        count: character.memberships.count,
        label: 'party memberships'
      }
    }
  end

  def handle_associations(character)
    # Destroy schticks (they belong to character)
    character.schticks.destroy_all
    
    # Remove character from weapons (clear carries relationship)
    character.carries.destroy_all
    
    # Remove from active fights
    character.shots.destroy_all
    
    # Remove from parties
    character.memberships.destroy_all
  end

  def entity_type_name
    'character'
  end
end