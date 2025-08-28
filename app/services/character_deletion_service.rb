class CharacterDeletionService < EntityDeletionService
  protected

  def association_counts(character)
    {
      'schticks' => {
        count: character.schticks.count,
        label: 'schticks'
      },
      'weapons' => {
        count: character.character_weapons.count,
        label: 'weapons carried'
      },
      'shots' => {
        count: character.shots.count,
        label: 'active fight positions'
      },
      'party_memberships' => {
        count: character.character_party_memberships.count,
        label: 'party memberships'
      }
    }
  end

  def handle_associations(character)
    # Destroy schticks (they belong to character)
    character.schticks.destroy_all
    
    # Remove character from weapons (clear carries relationship)
    character.character_weapons.destroy_all
    
    # Remove from active fights
    character.shots.destroy_all
    
    # Remove from parties
    character.character_party_memberships.destroy_all
  end

  def entity_type_name
    'character'
  end
end