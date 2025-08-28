class SiteDeletionService < EntityDeletionService
  protected

  def association_counts(site)
    # Sites typically don't have associations that block deletion
    {}
  end

  def handle_associations(site)
    # No associations to handle for sites
  end

  def entity_type_name
    'site'
  end
end