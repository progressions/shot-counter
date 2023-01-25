namespace :schticks do
  task import: :environment do
    campaign = Campaign.find_by(title: "Born to Revengeance")
    data = YAML.load_file("./martial_arts.yml")

    data.each do |category|
      category["paths"].each do |path|
        path["schticks"].each do |attributes|
          schtick = campaign.schticks.new(
            category: category["name"].titleize,
            path: path["path"].titleize,
            title: attributes["title"].titleize,
            description: attributes["description"],
            bonus: attributes["bonus"],
          )
          if attributes["prerequisite"]
            prereq_name = attributes["prerequisite"].gsub(".", "")
            schtick.schtick = campaign.schticks.find_by(title: prereq_name)
          end
          schtick.save
        end
      end
    end
  end
end
