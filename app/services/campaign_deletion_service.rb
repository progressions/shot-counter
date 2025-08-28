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
      },
      'schticks' => {
        count: campaign.schticks.count,
        label: 'schticks'
      },
      'weapons' => {
        count: campaign.weapons.count,
        label: 'weapons'
      }
    }
  end

  def handle_associations(campaign)
    # First, destroy all join table records to free up associations
    # These prevent other entities from being deleted due to foreign key constraints
    
    # Destroy campaign memberships (user-campaign join table)
    CampaignMembership.where(campaign_id: campaign.id).delete_all
    
    # Destroy party memberships for parties in this campaign
    party_ids = campaign.parties.pluck(:id)
    Membership.where(party_id: party_ids).delete_all if party_ids.any?
    
    # Destroy attunements (character-site join table)
    Attunement.joins(:site).where(sites: { campaign_id: campaign.id }).delete_all
    
    # Destroy carries (character-weapon join table)
    # Need to handle ALL carries that reference this campaign's weapons or characters
    # This includes cases where characters from other campaigns might carry weapons from this campaign
    character_ids = campaign.characters.pluck(:id)
    weapon_ids = campaign.weapons.pluck(:id)
    
    # Delete all carries involving these characters OR these weapons
    if character_ids.any? || weapon_ids.any?
      Carry.where(character_id: character_ids).or(Carry.where(weapon_id: weapon_ids)).delete_all
    end
    
    # Destroy character-schtick associations
    # Need to handle ALL character-schtick associations for this campaign's schticks or characters
    schtick_ids = campaign.schticks.pluck(:id)
    
    # Delete all character-schtick associations involving these characters OR these schticks
    if character_ids.any? || schtick_ids.any?
      CharacterSchtick.where(character_id: character_ids).or(CharacterSchtick.where(schtick_id: schtick_ids)).delete_all
    end
    
    # Destroy shots and fight events (characters/vehicles in fights)
    fight_ids = campaign.fights.pluck(:id)
    if fight_ids.any?
      Shot.where(fight_id: fight_ids).delete_all
      FightEvent.where(fight_id: fight_ids).delete_all
    end
    
    # Clear faction associations for characters and junctures
    # This must be done before deleting factions
    # Need to handle ALL references to this campaign's factions (including from other campaigns)
    faction_ids = campaign.factions.pluck(:id)
    if faction_ids.any?
      Character.where(faction_id: faction_ids).update_all(faction_id: nil)
      Juncture.where(faction_id: faction_ids).update_all(faction_id: nil)
    end
    
    # Delete all campaign-associated records (campaign_id is NOT NULL for these)
    # Use Model.where instead of association to avoid Rails trying to nullify
    # Order matters - delete things that reference other things first
    
    # Delete entities that don't reference anything else
    Fight.where(campaign_id: campaign.id).delete_all
    Party.where(campaign_id: campaign.id).delete_all
    Site.where(campaign_id: campaign.id).delete_all
    
    # Delete entities that may reference factions (but we've already nullified those references)
    Character.where(campaign_id: campaign.id).delete_all
    Vehicle.where(campaign_id: campaign.id).delete_all
    Juncture.where(campaign_id: campaign.id).delete_all
    
    # Delete Schticks and Weapons after Characters (join tables already cleared)
    Schtick.where(campaign_id: campaign.id).delete_all
    Weapon.where(campaign_id: campaign.id).delete_all
    
    # Finally delete factions (nothing references them anymore)
    Faction.where(campaign_id: campaign.id).delete_all
  end

  def entity_type_name
    'campaign'
  end
end