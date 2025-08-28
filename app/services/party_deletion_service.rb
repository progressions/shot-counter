class PartyDeletionService < EntityDeletionService
  protected

  def association_counts(party)
    {
      'characters' => {
        count: party.character_party_memberships.count,
        label: 'party members'
      }
    }
  end

  def handle_associations(party)
    # Remove all character memberships
    party.character_party_memberships.destroy_all
  end

  def entity_type_name
    'party'
  end
end