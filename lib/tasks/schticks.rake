namespace :schticks do
  task import: :environment do
    campaign = Campaign.find_by(title: "Born to Revengeance")
    data = YAML.load_file("./martial_arts.yml")
    data["martial_arts"].each do |path|
      path["schticks"].each do |attributes|
        schtick = campaign.schticks.new(
          category: "Martial Arts",
          path: path["path"],
          title: attributes["title"],
          description: attributes["description"]
        )
        schtick.save
      end
    end
  end
end
