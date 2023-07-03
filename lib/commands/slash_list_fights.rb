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
    CurrentCampaign.set(campaign)
    event.respond(content: "Campaign set to #{campaign.name}")
  end

  Bot.register_application_command(:list, 'List all available fights.') do |cmd|
  end

  Bot.application_command(:list) do |event|
    campaign = CurrentCampaign.get
    fights = campaign.fights.active.order("created_at DESC")

    message = "\n\n**FIGHTS**\n"
    message += "=========\n"
    message += fights.map(&:name).join("\n")
    event.respond(content: message)
  end

  Bot.register_application_command(:reset, 'Reset the current fight, moving all characters to shot 0.') do |cmd|
  end

  Bot.application_command(:reset) do |event|
    fight = CurrentFight.get
    if fight.nil?
      event.respond(content: "There is no current fight. /start a fight first!")
      return
    end

    fight.characters.update_all(current_shot: nil)
    CurrentSequence.set(1)
    event.respond(content: FightPoster.shots(fight))
  end
end
