namespace :campaign do
  desc "Sync template content to an existing campaign"
  task :sync_template, [:campaign_id] => :environment do |t, args|
    unless args[:campaign_id]
      puts "Error: campaign_id is required"
      puts "Usage: rails campaign:sync_template[campaign_id]"
      puts "       rails campaign:sync_template[campaign_id,source_campaign_id]"
      exit 1
    end

    campaign_id = args[:campaign_id]
    source_id = ENV['SOURCE_CAMPAIGN_ID']
    dry_run = ENV['DRY_RUN'] != 'false'

    begin
      service = CampaignTemplateSyncService.new(
        campaign_id,
        source_campaign_id: source_id,
        dry_run: dry_run
      )

      service.sync!
    rescue => e
      puts "\nError: #{e.message}"
      puts e.backtrace.first(5).join("\n")
      exit 1
    end
  end

  desc "List all campaigns with their IDs"
  task list: :environment do
    campaigns = Campaign.order(:name)

    puts "\n" + "=" * 80
    puts "Available Campaigns"
    puts "=" * 80 + "\n"

    campaigns.each do |campaign|
      template_marker = campaign.is_master_template ? " [MASTER TEMPLATE]" : ""
      seeded_marker = campaign.seeded_at ? " (seeded)" : ""
      puts "#{campaign.id.ljust(36)} | #{campaign.name}#{template_marker}#{seeded_marker}"
    end

    puts "\n" + "=" * 80 + "\n"
    puts "To sync a campaign:"
    puts "  DRY_RUN=true rails campaign:sync_template[campaign_id]"
    puts "  DRY_RUN=false rails campaign:sync_template[campaign_id]"
    puts ""
    puts "To specify a custom source campaign:"
    puts "  SOURCE_CAMPAIGN_ID=source_id DRY_RUN=true rails campaign:sync_template[target_id]"
    puts "=" * 80 + "\n"
  end
end
