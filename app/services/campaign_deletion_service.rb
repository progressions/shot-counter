class CampaignDeletionService < EntityDeletionService
  protected

  def association_counts(campaign)
    {
      'characters' => {
        count: campaign.characters.count,
        label: 'characters'
      },
      'vehicles' => {
        count: campaign.vehicles.count,
        label: 'vehicles'
      },
      'fights' => {
        count: campaign.fights.count,
        label: 'active fights'
      },
      'sites' => {
        count: campaign.sites.count,
        label: 'sites'
      },
      'parties' => {
        count: campaign.parties.count,
        label: 'parties'
      },
      'factions' => {
        count: campaign.factions.count,
        label: 'factions'
      },
      'junctures' => {
        count: campaign.junctures.count,
        label: 'junctures'
      }
    }
  end

  def handle_associations(campaign)
    # Nullify campaign_id for records that allow null
    campaign.characters.update_all(campaign_id: nil)
    campaign.vehicles.update_all(campaign_id: nil)
    campaign.fights.update_all(campaign_id: nil)
    campaign.sites.update_all(campaign_id: nil)
    campaign.junctures.update_all(campaign_id: nil)
    
    # Destroy records that have non-null campaign_id constraint
    campaign.parties.destroy_all
    campaign.factions.destroy_all
  end

  def entity_type_name
    'campaign'
  end
end