class UserDeletionService < EntityDeletionService
  protected

  def association_counts(user)
    {
      'characters' => {
        count: user.characters.count,
        label: 'characters owned'
      },
      'vehicles' => {
        count: user.vehicles.count,
        label: 'vehicles owned'
      },
      'campaigns_owned' => {
        count: user.campaigns.count,
        label: 'campaigns owned'
      },
      'campaign_memberships' => {
        count: user.campaign_memberships.count,
        label: 'campaign memberships'
      },
      'invitations_sent' => {
        count: user.invitations.count,
        label: 'invitations sent'
      }
    }
  end

  def handle_associations(user)
    # Nullify user_id for characters (don't delete them)
    user.characters.update_all(user_id: nil)
    
    # Nullify user_id for vehicles (don't delete them)
    user.vehicles.update_all(user_id: nil)
    
    # Transfer campaign ownership or destroy campaigns
    user.campaigns.destroy_all
    
    # Remove from campaign memberships
    user.campaign_memberships.destroy_all
    
    # Cancel pending invitations
    user.invitations.destroy_all
  end

  def entity_type_name
    'user'
  end
end