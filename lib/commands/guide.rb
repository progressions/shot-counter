module GuideCommands
  extend Discordrb::Commands::CommandContainer

  GUIDES = {
    boost: "boost",
    dice: "dice",
    dodge: "dodge"
  }.freeze

  Bot.register_application_command(:guide, "Feng Shui Action Guide") do |cmd|
    cmd.string(:guide, "The name of the guide to display", choices: GUIDES, required: true)
  end

  Bot.application_command(:guide) do |event|
    name = event.options["guide"]
    file = filename(name)
    message = ERB.new(file.read, trim_mode: "-").result(binding)

    event.respond(content: message)
  end

  def self.filename(name)
    Rails.root.join("app", "views", "guides", "#{name.downcase.underscore}.md.erb")
  end
end
