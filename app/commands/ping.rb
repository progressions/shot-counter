module Ping
  extend Discordrb::Commands::CommandContainer

  Bot.message(content: 'Ping!') do |event|
    event.respond 'Pong Message!'
  end

  Bot.command(:ping) do |event|
    event.respond 'Pong Command!'
  end
end
