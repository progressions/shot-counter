namespace :schticks do
  task import: :environment do
    campaign = Campaign.find_by(name: "Born to Revengeance")
    data = YAML.load_file("./schticks.yml")

    data.each do |category|
      category["paths"].each do |path|
        path["schticks"].each do |attributes|
          schtick = campaign.schticks.new(
            category: category["name"].nameize,
            path: path["path"].nameize,
            name: attributes["name"].nameize,
            description: attributes["description"],
            bonus: attributes["bonus"],
          )
          if attributes["prerequisite"]
            prereq_name = attributes["prerequisite"].gsub(".", "")
            schtick.schtick = campaign.schticks.find_by(name: prereq_name)
          end
          schtick.save
        end
      end
    end
  end
end
