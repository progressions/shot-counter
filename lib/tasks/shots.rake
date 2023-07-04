namespace :shots do
  task convert: :environment do
    FightCharacter.find_each do |fc|
      Shot.create(fc.attributes.except(:id, :created_at, :updated_at))
    end
  end
end
