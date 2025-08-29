class SchtickDeletionService < EntityDeletionService
  protected

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
        label: 'schticks requiring this'
      }
    }
  end

  def handle_associations(schtick)
    # Remove schtick from all characters
    schtick.character_schticks.destroy_all
    
    # Clear prerequisite relationships - remove this as prerequisite from other schticks
    Schtick.where(prerequisite: schtick).update_all(prerequisite_id: nil)
  end

  def entity_type_name
    'schtick'
  end
end