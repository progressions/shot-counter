namespace :schticks do
  task import: :environment do
    campaign = Campaign.find_by(name: "Born to Revengeance")
    data = YAML.load_file("./lib/schticks/all.yml")

    data.each do |category|
      category["paths"].each do |path|
        path["schticks"].each do |attributes|
          schtick = campaign.schticks.new(
            category: category["name"].titleize,
            path: path["name"]&.titleize,
            name: attributes["name"].titleize,
            description: attributes["description"],
            bonus: attributes["bonus"],
          )
          if attributes["prerequisite"]
            prereq_name = attributes["prerequisite"].gsub(".", "")
            schtick.prerequisite = campaign.schticks.find_by(name: prereq_name)
          end
          schtick.save
        rescue => e
          binding.pry
        end
      end
    end
  end
end
