class PartyDeletionService < EntityDeletionService
  protected

  # No blocking constraints - parties can always be deleted
  def blocking_constraints(party)
    {}
  end

  def association_counts(party)
    {
      'memberships' => {
        count: party.memberships.count,
        label: 'party members'
      }
    }
  end

  def cleanup_owned_associations(party)
    # Always remove all memberships when deleting party
    party.memberships.destroy_all
  end

  # Legacy method for compatibility
  def handle_associations(party)
    cleanup_owned_associations(party)
  end

  def entity_type_name
    'party'
  end
end