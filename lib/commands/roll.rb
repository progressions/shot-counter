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
    swerve = DiceRoller.swerve
    message = DiceRoller.discord(swerve, event.user.display_name)

    event.respond(content: message)
  end

end
