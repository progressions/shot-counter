namespace :schticks do
  task import: :environment do
    campaign = Campaign.find_by(title: "Born to Revengeance")
    data = YAML.load_file("./martial_arts.yml")
    data["martial_arts"].each do |path|
      path["schticks"].each do |attributes|
        schtick = campaign.schticks.new(
          category: data["name"].titleize,
          path: path["path"].titleize,
          title: attributes["title"].titleize,
          description: attributes["description"]
        )
        schtick.save
      end
    end
  end
end
