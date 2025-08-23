class CampaignSeederService
  class << self
    def seed_campaign(campaign)
      return false if campaign.seeded_at.present?
      return false unless campaign.persisted?

      master_template = Campaign.find_by(is_master_template: true)
      return false unless master_template

      Rails.logger.info "Seeding campaign #{campaign.name} (ID: #{campaign.id}) from master template"

      ActiveRecord::Base.transaction do
        # Duplicate template characters
        duplicate_characters(master_template, campaign)

        # Mark campaign as seeded
        campaign.update!(seeded_at: Time.current)
      end

      Rails.logger.info "Successfully seeded campaign #{campaign.name}"
      true
    rescue StandardError => e
      Rails.logger.error "Failed to seed campaign #{campaign.name}: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      false
    end

    private

    def duplicate_characters(source_campaign, target_campaign)
      template_characters = source_campaign.characters.where(is_template: true)
      
      Rails.logger.info "Duplicating #{template_characters.count} template characters"

      template_characters.each do |template_character|
        duplicated_character = CharacterDuplicatorService.duplicate_character(template_character, target_campaign.user)
        duplicated_character.campaign = target_campaign
        
        if duplicated_character.save
          Rails.logger.info "Duplicated character: #{duplicated_character.name}"
        else
          Rails.logger.error "Failed to duplicate character #{template_character.name}: #{duplicated_character.errors.full_messages.join(', ')}"
          raise ActiveRecord::RecordInvalid, duplicated_character
        end
      end
    end
  end
end