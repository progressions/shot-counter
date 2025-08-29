class CharacterDeletionService < EntityDeletionService
  protected

  # Only associations that should block deletion without force
  def blocking_constraints(character)
    {
      'shots' => {
        count: character.shots.count,
        label: 'active fight positions'
      },
      'party_memberships' => {
        count: character.memberships.count,
        label: 'party memberships'
      }
    }.select { |_, data| data[:count] > 0 }
  end

  # All associations for reference (used in handle_associations)
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


  def cleanup_owned_associations(character)
    # Always clean up these - they belong to the character
    character.schticks.destroy_all
    character.carries.destroy_all
  end

  def handle_blocking_associations(character)
    # Only clean these up when force is true
    character.shots.destroy_all
    character.memberships.destroy_all
  end

  # Legacy method for compatibility (kept for force delete)
  def handle_associations(character)
    cleanup_owned_associations(character)
    handle_blocking_associations(character)
  end

  def entity_type_name
    'character'
  end
end