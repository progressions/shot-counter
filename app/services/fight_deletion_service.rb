class FightDeletionService < EntityDeletionService
  protected

  def association_counts(fight)
    {
      'shots' => {
        count: fight.shots.count,
        label: 'character positions'
      },
      'effects' => {
        count: fight.effects.count,
        label: 'active effects'
      }
    }
  end

  def handle_associations(fight)
    # Destroy all shots (character/vehicle positions in fight)
    fight.shots.destroy_all
    
    # Destroy all effects
    fight.effects.destroy_all
  end

  def entity_type_name
    'fight'
  end
end