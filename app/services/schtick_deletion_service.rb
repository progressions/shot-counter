class SchtickDeletionService < EntityDeletionService
  protected

  def association_counts(schtick)
    {
      'characters' => {
        count: schtick.character_schticks.count,
        label: 'characters with schtick'
      },
      'prerequisite_for' => {
        count: schtick.reverse_paths.count,
        label: 'schticks requiring this'
      }
    }
  end

  def handle_associations(schtick)
    # Remove schtick from all characters
    schtick.character_schticks.destroy_all
    
    # Clear prerequisite relationships
    schtick.paths.destroy_all
    schtick.reverse_paths.destroy_all
  end

  def entity_type_name
    'schtick'
  end
end