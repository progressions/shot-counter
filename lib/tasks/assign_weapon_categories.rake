desc "Assign categories to weapons from YAML file"
task assign_weapon_categories: :environment do
  yaml_path = Rails.root.join("lib", "weapons", "weapons.yml")
  data = YAML.load_file(yaml_path)

  updated_count = 0

  data.each do |juncture_data|
    juncture_data["categories"].each do |category_data|
      category = category_data["name"]
      next if category.blank?

      category_data["weapons"].each do |weapon_data|
        name = weapon_data["name"].gsub(/\s+\d+\/\d+\/[\d-]+\s*$/, "").strip

        Weapon.where("category IS NULL OR category = ?", "")
              .where("LOWER(name) LIKE ?", "%#{name.downcase}%")
              .update_all(category: category)

        updated_count += Weapon.where("LOWER(name) LIKE ?", "%#{name.downcase}%")
                               .where(category: category).count
      end
    end
  end

  puts "✓ Updated #{updated_count} weapons with categories"
end
