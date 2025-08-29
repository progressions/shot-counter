class SchtickDeletionService < EntityDeletionService
  protected

  # Both character associations and prerequisite relationships should block deletion
  def blocking_constraints(schtick)
    dependent_schticks = Schtick.where(prerequisite: schtick)
    
    constraints = {}
    
    character_count = schtick.character_schticks.count
    if character_count > 0
      constraints['characters'] = {
        count: character_count,
        label: 'characters with schtick'
      }
    end
    
    if dependent_schticks.count > 0
      constraints['prerequisite_for'] = {
        count: dependent_schticks.count,
        label: 'schticks requiring this as prerequisite'
      }
    end
    
    constraints
  end

  def association_counts(schtick)
    # Find schticks that have this schtick as a prerequisite
    dependent_schticks = Schtick.where(prerequisite: schtick)
    
    {
      'characters' => {
        count: schtick.character_schticks.count,
        label: 'characters with schtick'
      },
      'prerequisite_for' => {
        count: dependent_schticks.count,
        label: 'schticks requiring this as prerequisite'
      }
    }
  end

  def cleanup_owned_associations(schtick)
    # Always remove schtick from all characters (safe to clean up)
    schtick.character_schticks.destroy_all
  end

  def handle_blocking_associations(schtick)
    # Only clear prerequisite relationships when force=true
    Schtick.where(prerequisite: schtick).update_all(prerequisite_id: nil)
  end

  # Legacy method for compatibility
  def handle_associations(schtick)
    cleanup_owned_associations(schtick)
    handle_blocking_associations(schtick)
  end

  def entity_type_name
    'schtick'
  end
end