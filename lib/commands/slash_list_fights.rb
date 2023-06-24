module SlashListFights
  extend Discordrb::Commands::CommandContainer

  Bot.register_application_command(:list, 'List all available fights.') do |cmd|
  end

  Bot.application_command(:list) do |event|
    fights = Fight.active.order("created_at DESC")

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
