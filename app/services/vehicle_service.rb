module VehicleService
  class << self
    def archetypes
      # load archetypes from YAML file at config/vehicles.yml
      @archetypes ||= YAML.load_file("#{Rails.root}/config/vehicles.yml")
    end
  end
end
