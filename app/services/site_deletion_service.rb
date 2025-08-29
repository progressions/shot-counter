class SiteDeletionService < EntityDeletionService
  protected

  def association_counts(site)
    {
      'attunements' => {
        count: site.attunements.count,
        label: 'character attunements'
      }
    }
  end

  def handle_associations(site)
    # Remove all attunements (character-site relationships)
    site.attunements.destroy_all
  end

  def entity_type_name
    'site'
  end
end