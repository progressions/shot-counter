module Roll
  extend Discordrb::Commands::CommandContainer

  Bot.register_application_command(:roll, "Roll dice") do |cmd|
  end

  Bot.application_command(:roll) do |event|
    roll = DiceRoller.die_roll
    event.respond(content: "Rolling dice: #{roll}")
  end

  Bot.register_application_command(:swerve, "Roll a swerve, positive and negative exploding dice") do |cmd|
  end

  Bot.application_command(:swerve) do |event|
    username = event.user.display_name
    swerve = DiceRoller.swerve
    DiceRoller.save_swerve(swerve, username)
    messages = ["Rolling swerve #{username ? 'for ' + username : ''}"]
    messages << DiceRoller.discord(swerve, event.user.display_name)

    event.respond(content: messages.join("\n"))
  end

  Bot.register_application_command(:swerves, "Show your swerves") do |cmd|
  end

  Bot.application_command(:swerves) do |event|
    username = event.user.display_name
    messages = ["Swerves for #{username}"]
    swerves = DiceRoller.load_swerves(username)
    swerves.each do |swerve|
      if swerve[:rolled_at]
        # parse the date into the format "2023-07-01 7:00 PM"
        rolled_at = DateTime.parse(swerve[:rolled_at]).strftime("%Y-%m-%d %l:%M %p")
        messages << "Rolled on #{rolled_at}"
      end
      message = DiceRoller.discord(swerve, username)
      messages << message
    end

    if swerves.empty?
      event.respond(content: "No swerves found for #{username}") if swerves.empty?
    else
      event.respond(content: messages.join("\n\n"))
    end
  end

  Bot.register_application_command(:clear_swerves, "Clear your swerves") do |cmd|
  end

  Bot.application_command(:clear_swerves) do |event|
    DiceRoller.clear_swerves(event.user.display_name)
    event.respond(content: "Cleared swerves for #{event.user.display_name}")
  end

end
