class CampaignSeederService
  class << self
    def seed_campaign(campaign)
      return false if campaign.seeded_at.present?
      return false unless campaign.persisted?

      master_template = Campaign.find_by(is_master_template: true)
      return false unless master_template

      Rails.logger.info "Seeding campaign #{campaign.name} (ID: #{campaign.id}) from master template"

      return copy_campaign_content(master_template, campaign)
    end

    def copy_campaign_content(source_campaign, target_campaign)
      return false unless source_campaign.persisted? && target_campaign.persisted?

      Rails.logger.info "Copying content from campaign #{source_campaign.name} to #{target_campaign.name}"

      ActiveRecord::Base.transaction do
        # Copy schticks and weapons first so they exist when characters reference them
        duplicate_schticks(source_campaign, target_campaign)
        duplicate_weapons(source_campaign, target_campaign)
        
        # Copy factions before junctures since junctures reference factions
        duplicate_factions(source_campaign, target_campaign)
        duplicate_junctures(source_campaign, target_campaign)
        
        # Copy characters and vehicles last so they can reference the duplicated entities
        duplicate_characters(source_campaign, target_campaign)
        duplicate_vehicles(source_campaign, target_campaign)

        # Mark campaign as seeded only if this was called from seed_campaign
        target_campaign.update!(seeded_at: Time.current) if target_campaign.seeded_at.nil?
      end

      Rails.logger.info "Successfully copied content to campaign #{target_campaign.name}"
      true
    rescue StandardError => e
      Rails.logger.error "Failed to copy campaign content: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      false
    end

    private

    def duplicate_characters(source_campaign, target_campaign)
      characters = source_campaign.characters.where(is_template: true)
      
      Rails.logger.info "Duplicating #{characters.count} characters"

      characters.each do |character|
        # Pass the target_campaign as the third parameter so it uses the correct campaign for name checking
        duplicated_character = CharacterDuplicatorService.duplicate_character(character, target_campaign.user, target_campaign)
        
        if duplicated_character.save
          # Apply associations after the character is saved and has an ID
          CharacterDuplicatorService.apply_associations(duplicated_character)
          Rails.logger.info "Duplicated character: #{duplicated_character.name}"
        else
          Rails.logger.error "Failed to duplicate character #{character.name}: #{duplicated_character.errors.full_messages.join(', ')}"
          raise ActiveRecord::RecordInvalid, duplicated_character
        end
      end
    end

    def duplicate_vehicles(source_campaign, target_campaign)
      vehicles = source_campaign.vehicles
      
      Rails.logger.info "Duplicating #{vehicles.count} vehicles"

      vehicles.each do |vehicle|
        duplicated_vehicle = VehicleDuplicatorService.duplicate_vehicle(vehicle, target_campaign.user, target_campaign)
        
        if duplicated_vehicle.save
          Rails.logger.info "Duplicated vehicle: #{duplicated_vehicle.name}"
        else
          Rails.logger.error "Failed to duplicate vehicle #{vehicle.name}: #{duplicated_vehicle.errors.full_messages.join(', ')}"
          raise ActiveRecord::RecordInvalid, duplicated_vehicle
        end
      end
    end

    def duplicate_schticks(source_campaign, target_campaign)
      schticks = source_campaign.schticks
      
      Rails.logger.info "Duplicating #{schticks.count} schticks"

      schticks.each do |schtick|
        duplicated_schtick = SchtickDuplicatorService.duplicate_schtick(schtick, target_campaign)
        
        if duplicated_schtick.save
          Rails.logger.info "Duplicated schtick: #{duplicated_schtick.name}"
        else
          Rails.logger.error "Failed to duplicate schtick #{schtick.name}: #{duplicated_schtick.errors.full_messages.join(', ')}"
          raise ActiveRecord::RecordInvalid, duplicated_schtick
        end
      end
    end

    def duplicate_weapons(source_campaign, target_campaign)
      weapons = source_campaign.weapons
      
      Rails.logger.info "Duplicating #{weapons.count} weapons"

      weapons.each do |weapon|
        duplicated_weapon = WeaponDuplicatorService.duplicate_weapon(weapon, target_campaign)
        
        if duplicated_weapon.save
          Rails.logger.info "Duplicated weapon: #{duplicated_weapon.name}"
        else
          Rails.logger.error "Failed to duplicate weapon #{weapon.name}: #{duplicated_weapon.errors.full_messages.join(', ')}"
          raise ActiveRecord::RecordInvalid, duplicated_weapon
        end
      end
    end

    def duplicate_junctures(source_campaign, target_campaign)
      junctures = source_campaign.junctures
      
      Rails.logger.info "Duplicating #{junctures.count} junctures"
      
      # Create faction mapping for juncture associations
      faction_mapping = {}
      source_campaign.factions.each do |source_faction|
        target_faction = target_campaign.factions.find_by(name: source_faction.name)
        faction_mapping[source_faction.id] = target_faction if target_faction
      end

      junctures.each do |juncture|
        duplicated_juncture = JunctureDuplicatorService.duplicate_juncture(juncture, target_campaign, faction_mapping)
        
        if duplicated_juncture.save
          Rails.logger.info "Duplicated juncture: #{duplicated_juncture.name}"
        else
          Rails.logger.error "Failed to duplicate juncture #{juncture.name}: #{duplicated_juncture.errors.full_messages.join(', ')}"
          raise ActiveRecord::RecordInvalid, duplicated_juncture
        end
      end
    end

    def duplicate_factions(source_campaign, target_campaign)
      factions = source_campaign.factions
      
      Rails.logger.info "Duplicating #{factions.count} factions"

      factions.each do |faction|
        duplicated_faction = FactionDuplicatorService.duplicate_faction(faction, target_campaign)
        
        if duplicated_faction.save
          Rails.logger.info "Duplicated faction: #{duplicated_faction.name}"
        else
          Rails.logger.error "Failed to duplicate faction #{faction.name}: #{duplicated_faction.errors.full_messages.join(', ')}"
          raise ActiveRecord::RecordInvalid, duplicated_faction
        end
      end
    end
  end
end