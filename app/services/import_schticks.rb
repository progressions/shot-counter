module ImportSchticks
  class << self
    def call(data, campaign)
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
              schtick.prerequisite = campaign.schticks.find_by(title: prereq_name)
            end
            schtick.save
          end
        end
      end
    end
  end
end
