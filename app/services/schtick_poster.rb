module SchtickPoster
  class << self
    def show(schtick)
      filename = Rails.root.join("app", "views", "schticks", "show.md.erb")
      ERB.new(filename.read, trim_mode: "-").result(binding)
    end

  end
end
