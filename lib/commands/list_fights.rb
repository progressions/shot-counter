module SlashListFights
  extend Discordrb::Commands::CommandContainer

  Bot.register_application_command(:campaigns, 'List campaigns') do |cmd|
  end

  Bot.application_command(:campaigns) do |event|
    campaigns = Campaign.all
    message = "\n\n**CAMPAIGNS**\n"
    message += "============\n"
    message += campaigns.map(&:name).join("\n")

    event.respond(content: message)
  end

  Bot.register_application_command(:campaign, 'Start a campaign.') do |cmd|
    cmd.string(:name, "Campaign name")
  end

  Bot.application_command(:campaign) do |event|
    name = event.options[:name] || event.options["name"]

    campaign = Campaign.where("name ILIKE ?", "%#{name}%").first
    if campaign.nil?
      event.respond(content: "No campaign found with that name.")
      return
    end
    CurrentCampaign.set(server_id: event.server_id, campaign: campaign)
    event.respond(content: "Campaign set to #{campaign.name}")
  end

  Bot.register_application_command(:list, 'List all available fights.') do |cmd|
  end

  Bot.application_command(:list) do |event|
    puts "event.server_id: #{event.server_id}"
    Rails.logger.info("DISCORD: Listing fights for channel_id: #{event.channel_id}")
    campaign = CurrentCampaign.get(server_id: event.server_id)
    if campaign.nil?
      event.respond(content: "No current campaign.")
      return
    end
    fights = campaign.fights.active.order("created_at DESC")

    message = "\n\n**FIGHTS**\n"
    message += "=========\n"
    message += fights.map(&:name).join("\n")
    event.respond(content: message)
  end
end
