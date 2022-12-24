module Act
  extend Discordrb::Commands::CommandContainer

  Bot.command(:commands) do |event|
    message = <<-TEXT
      /start <Fight name>           - Start a fight
      /stop                         - Stop the current fight
      /reset                        - Reset everyone's current shot to start a new sequence
      /add <Character> <num>        - Add a character to the fight on shot [num]
      /act <Character> [shots]      - The character acts, specify a number of shots (default is 3)
      /update                       - Show the current shot counter
    TEXT
    event.respond(message)
  end

  Bot.command(:act) do |event|
    fight = get_current_fight
    if fight.nil?
      event.respond("There is no current fight. /start a fight first!")
      return
    end

    args = event.content.split(" ")[1..]
    shots = 3
    if args.last =~ /\A\d+\Z/
      name = args[0...-1].join(" ")
      shots = args.last
    else
      name = args[0..].join(" ")
    end

    character = fight.characters.where("name ILIKE ?", name.downcase).first

    if character.nil?
      event.respond("Can't find that character!")
      return
    end

    character.act!(shots)
    FightPoster.post_shots(fight)

    event.respond(FightPoster.shots(fight))
  end

  Bot.command(:set) do |event|
    fight = get_current_fight
    if fight.nil?
      event.respond("There is no current fight. /start a fight first!")
      return
    end

    args = event.content.split(" ")[1..]
    if args.last =~ /\A\d+\Z/
      name = args[0...-1].join(" ")
      shot = args.last
    else
      event.respond("End your command with a number!")
      return
    end

    character = fight.characters.where("name ILIKE ?", name.downcase).first

    if fight.nil?
      event.respond("Can't find that character!")
      return
    end

    character.update(current_shot: shot)
    FightPoster.post_shots(fight)

    event.respond(FightPoster.shots(fight))
  end

  Bot.command(:start) do |event|
    args = event.content.split(" ")[1..]
    fight_name = args.join(" ")
    fight = Fight.find_or_create_by(name: fight_name)
    if fight
      set_current_fight(fight)
      event.respond("Starting fight: #{fight.name}")
    else
      event.respond("Couldn't find that fight!")
    end
  end

  Bot.command(:stop) do |event|
    fight = get_current_fight
    if fight
      set_current_fight(nil)
      event.respond("Stopping fight: #{fight.name}")
    else
      event.respond("Couldn't find that fight!")
    end
  end

  Bot.command(:current) do |event|
    fight = get_current_fight
    if fight
      event.respond("Current fight is #{fight.name}")
    else
      event.respond("There is no current fight.")
    end
  end

  Bot.command(:reset) do |event|
    fight = get_current_fight
    if fight.nil?
      event.respond("There is no current fight. /start a fight first!")
      return
    end

    fight.characters.update_all(current_shot: nil)
    event.respond(FightPoster.shots(fight))
  end

  Bot.command(:update) do |event|
    fight = get_current_fight
    if fight
      FightPoster.post_shots(fight)
      event.respond(FightPoster.shots(fight))
    else
      event.respond("There is no current fight.")
    end
  end

  Bot.command(:add) do |event|
    fight = get_current_fight

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

  class << self

    def redis
      @redis ||= Redis.new
    end

    def get_current_fight
      current_fight_id = redis.get("current_fight_id")
      Fight.find_by(id: current_fight_id)
    end

    def set_current_fight(fight=nil)
      redis.set("current_fight_id", fight&.id)
    end

  end

end
