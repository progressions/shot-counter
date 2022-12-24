module AddCharacter
  extend Discordrb::Commands::CommandContainer

  Bot.command(:add) do |event|
    fight = CurrentFight.get

    if fight.nil?
      event.respond("There is no current fight. /start a fight first!")
      return
    end

    args = event.content.split(" ")[1..]
    shot = nil
    if args.last =~ /\A\d+\Z/
      name = args[0...-1].join(" ")
      shot = args.last
    else
      name = args[1..]
    end
    fight.characters.create!(name: name, current_shot: shot)
    event.respond("Adding #{name} to shot #{shot} in the fight #{fight.name}")
  end
end
