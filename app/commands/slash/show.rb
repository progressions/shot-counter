module Slash
  module Show
    extend Discordrb::Commands::CommandContainer

    Bot.register_application_command(:show, 'Show current fight') do |cmd|
    end

    Bot.application_command(:show) do |event|
      fight = CurrentFight.get
      if !fight
        event.respond(content: "There is no current fight.")
        return
      end

      event.respond(content: FightPoster.shots(fight))
    end

  end
end
