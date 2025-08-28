class JunctureDeletionService < EntityDeletionService
  protected

  def association_counts(juncture)
    # Junctures typically don't have associations that block deletion
    {}
  end

  def handle_associations(juncture)
    # No associations to handle for junctures
  end

  def entity_type_name
    'juncture'
  end
end