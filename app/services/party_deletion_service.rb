class PartyDeletionService < EntityDeletionService
  protected

  def association_counts(party)
    {
      'memberships' => {
        count: party.memberships.count,
        label: 'party members'
      }
    }
  end

  def handle_associations(party)
    # Remove all memberships
    party.memberships.destroy_all
  end

  def entity_type_name
    'party'
  end
end