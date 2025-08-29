class EntityDeletionService
  def delete(entity, force: false)
    perform_deletion(entity, force: force)
  end

  protected

  def perform_deletion(entity, force: false)
    if can_delete?(entity, force: force)
      ActiveRecord::Base.transaction do
        handle_associations(entity) if force
        
        # Use destroy to properly handle dependent associations
        entity.destroy!
        { success: true, message: 'Entity successfully deleted' }
      end
    else
      constraints = check_constraints(entity)
      { 
        success: false, 
        error: unified_error_response(
          entity_type: entity_type_name,
          entity_id: entity.id,
          constraints: constraints
        )
      }
    end
  rescue => e
    Rails.logger.error "Deletion failed: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    { success: false, error: { message: "Failed to delete: #{e.message}" } }
  end

  def can_delete?(entity, force: false)
    return true if force
    check_constraints(entity).empty?
  end

  def check_constraints(entity)
    association_counts(entity).select { |_, data| data[:count] > 0 }
  end

  def unified_error_response(entity_type:, entity_id:, constraints:)
    {
      error_type: 'associations_exist',
      entity_type: entity_type,
      entity_id: entity_id,
      constraints: constraints,
      suggestions: [
        'Remove or reassign associated records first',
        'Use force=true parameter to cascade delete'
      ]
    }
  end

  # Methods that must be implemented by subclasses
  def association_counts(entity)
    raise NotImplementedError, "#{self.class} must implement association_counts"
  end

  def handle_associations(entity)
    raise NotImplementedError, "#{self.class} must implement handle_associations"
  end

  def entity_type_name
    raise NotImplementedError, "#{self.class} must implement entity_type_name"
  end
end