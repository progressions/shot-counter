class PartyDeletionService < EntityDeletionService
  protected

  # Parties with memberships cannot be deleted (unless forced)
  def blocking_constraints(party)
    constraints = {}
    
    membership_count = party.memberships.count
    if membership_count > 0
      constraints['memberships'] = {
        count: membership_count,
        label: 'party members'
      }
    end
    
    constraints
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