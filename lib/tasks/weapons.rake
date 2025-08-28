namespace :weapons do
  desc "List all unique weapon categories to help prepare images"
  task list_categories: :environment do
    # Find the Master Campaign
    master_campaign = Campaign.find_by(is_master_template: true)
    
    unless master_campaign
      puts "❌ Master Campaign not found! Looking for campaign with is_master_template: true"
      puts "Available campaigns with weapons:"
      Campaign.joins(:weapons).distinct.each do |campaign|
        puts "  - #{campaign.name} (ID: #{campaign.id}, weapons: #{campaign.weapons.count})"
      end
      exit 1
    end
    
    puts "\n🔫 Weapon Categories in Master Campaign: #{master_campaign.name}"
    puts "=" * 50
    
    categories = master_campaign.weapons.distinct.pluck(:category).compact.sort
    
    categories.each_with_index do |category, index|
      count = master_campaign.weapons.where(category: category).count
      with_images = master_campaign.weapons.where(category: category).joins(:image_attachment).count
      without_images = count - with_images
      
      status = without_images == 0 ? "✅" : "❌"
      puts "#{status} #{(index + 1).to_s.rjust(2)}. #{category.ljust(25)} (#{count} weapons, #{without_images} need images)"
    end
    
    puts "\nTotal categories in Master Campaign: #{categories.count}"
    puts "Total weapons in Master Campaign: #{master_campaign.weapons.count}"
    puts "Weapons with images: #{master_campaign.weapons.joins(:image_attachment).count}"
    puts "Weapons without images: #{master_campaign.weapons.left_joins(:image_attachment).where(active_storage_attachments: { id: nil }).count}"
    
    # Generate filename suggestions
    puts "\n📁 Expected image filenames:"
    puts "=" * 50
    categories.each do |category|
      filename = "#{category}.png"
      puts "  #{category.ljust(25)} -> #{filename}"
    end
  end
  
  desc "Attach images to weapons by category (DRY_RUN=true for preview, OVERWRITE=true to replace existing)"
  task attach_images: :environment do
    dry_run = ENV['DRY_RUN'].to_s.downcase == 'true'
    overwrite = ENV['OVERWRITE'].to_s.downcase == 'true'
    specific_category = ENV['CATEGORY']
    batch_size = (ENV['BATCH_SIZE'] || 100).to_i
    
    # Find the Master Campaign
    master_campaign = Campaign.find_by(is_master_template: true)
    
    unless master_campaign
      puts "❌ Master Campaign not found! Looking for campaign with is_master_template: true"
      exit 1
    end
    
    if dry_run
      puts "\n🔍 DRY RUN MODE - No changes will be made"
    else
      puts "\n🚀 LIVE MODE - Images will be attached"
    end
    
    puts "📍 Working with Master Campaign: #{master_campaign.name} (ID: #{master_campaign.id})"
    puts "🔄 Overwrite existing images: #{overwrite ? 'YES' : 'NO'}"
    
    # Define the image directory
    image_dir = Rails.root.join('lib', 'assets', 'weapon_images')
    
    unless Dir.exist?(image_dir)
      puts "❌ Image directory not found: #{image_dir}"
      puts "Please create the directory and add category images first."
      exit 1
    end
    
    # Category to image file mapping
    category_image_map = {}
    
    # Auto-detect images based on category names in Master Campaign
    categories = specific_category ? [specific_category] : master_campaign.weapons.distinct.pluck(:category).compact.sort
    
    categories.each do |category|
      # Try exact match first (e.g., "Handguns.png")
      filename = "#{category}.png"
      filepath = image_dir.join(filename)
      
      if File.exist?(filepath)
        category_image_map[category] = filepath
      else
        # Try with hyphens instead of spaces (e.g., "Big-Ass-Guns.png")
        filename_with_hyphens = "#{category.gsub(' ', '-')}.png"
        filepath_hyphen = image_dir.join(filename_with_hyphens)
        
        if File.exist?(filepath_hyphen)
          category_image_map[category] = filepath_hyphen
        else
          # Try .jpg version
          filepath_jpg = image_dir.join("#{category}.jpg")
          if File.exist?(filepath_jpg)
            category_image_map[category] = filepath_jpg
          else
            # Try lowercase with underscores (e.g., "big_ass_guns.png")
            filename_lowercase = "#{category.downcase.gsub(/\s+/, '_')}.png"
            filepath_lowercase = image_dir.join(filename_lowercase)
            if File.exist?(filepath_lowercase)
              category_image_map[category] = filepath_lowercase
            end
          end
        end
      end
    end
    
    # Report missing images
    missing_categories = categories - category_image_map.keys
    if missing_categories.any?
      puts "\n⚠️  Missing images for categories:"
      missing_categories.each do |cat|
        puts "  - #{cat} (expected: #{cat}.png)"
      end
    end
    
    # Process weapons
    puts "\n📎 Processing weapons..."
    puts "=" * 50
    
    total_processed = 0
    total_attached = 0
    total_skipped = 0
    total_errors = 0
    
    category_image_map.each do |category, image_path|
      puts "\n🏷️  Category: #{category}"
      puts "  Image: #{File.basename(image_path)}"
      
      # Get weapons for this category IN MASTER CAMPAIGN ONLY
      if overwrite
        # Get ALL weapons in this category (with or without images)
        weapons = master_campaign.weapons.where(category: category)
      else
        # Get only weapons WITHOUT images
        weapons = master_campaign.weapons
                        .where(category: category)
                        .left_joins(:image_attachment)
                        .where(active_storage_attachments: { id: nil })
      end
      
      count = weapons.count
      
      if count == 0
        puts "  ✅ All weapons in this category already have images"
        total_skipped += master_campaign.weapons.where(category: category).count
        next
      end
      
      puts "  Found #{count} weapons without images"
      
      unless dry_run
        # Process in batches to avoid memory issues
        weapons.find_in_batches(batch_size: batch_size).with_index do |batch, batch_index|
          print "  Processing batch #{batch_index + 1} (#{batch.size} weapons)..."
          
          batch.each do |weapon|
            begin
              # Purge existing image if overwriting
              if overwrite && weapon.image.attached?
                weapon.image.purge
              end
              
              # Attach the image
              file_extension = File.extname(image_path).delete('.')
              content_type = file_extension == 'png' ? 'image/png' : 'image/jpeg'
              
              weapon.image.attach(
                io: File.open(image_path),
                filename: "#{category.downcase.gsub(/\s+/, '_')}_#{weapon.id}.#{file_extension}",
                content_type: content_type
              )
              total_attached += 1
            rescue => e
              puts "\n    ❌ Error attaching image to #{weapon.name}: #{e.message}"
              total_errors += 1
            end
          end
          
          puts " ✅"
        end
      else
        puts "  Would attach image to #{count} weapons"
        total_attached += count
      end
      
      total_processed += count
    end
    
    # Final summary
    puts "\n" + "=" * 50
    puts "📊 Summary:"
    puts "  Categories processed: #{category_image_map.keys.count}"
    puts "  Weapons processed: #{total_processed}"
    puts "  Images attached: #{total_attached}"
    puts "  Weapons skipped (already have images): #{total_skipped}"
    puts "  Errors: #{total_errors}"
    
    if dry_run
      puts "\n💡 This was a dry run. To actually attach images, run:"
      puts "  rails weapons:attach_images"
    end
  end
  
  desc "Verify which weapons have images attached"
  task verify_images: :environment do
    # Find the Master Campaign
    master_campaign = Campaign.find_by(is_master_template: true)
    
    unless master_campaign
      puts "❌ Master Campaign not found! Looking for campaign with is_master_template: true"
      exit 1
    end
    
    puts "\n🔍 Verifying Weapon Images in Master Campaign: #{master_campaign.name}"
    puts "=" * 50
    
    categories = master_campaign.weapons.distinct.pluck(:category).compact.sort
    
    all_good = true
    
    categories.each do |category|
      total = master_campaign.weapons.where(category: category).count
      with_images = master_campaign.weapons.where(category: category).joins(:image_attachment).count
      without_images = total - with_images
      
      percentage = total > 0 ? (with_images.to_f / total * 100).round(1) : 0
      
      if without_images == 0
        puts "✅ #{category.ljust(25)} - All #{total} weapons have images"
      else
        puts "❌ #{category.ljust(25)} - #{with_images}/#{total} have images (#{percentage}%)"
        all_good = false
      end
    end
    
    puts "\n" + "=" * 50
    if all_good
      puts "✅ All weapons in Master Campaign have images attached!"
    else
      total_with = master_campaign.weapons.joins(:image_attachment).count
      total_without = master_campaign.weapons.left_joins(:image_attachment).where(active_storage_attachments: { id: nil }).count
      puts "📊 Master Campaign Overall: #{total_with} have images, #{total_without} need images"
    end
  end
  
  desc "Remove all images from Master Campaign weapons (useful for testing)"
  task remove_all_images: :environment do
    # Find the Master Campaign
    master_campaign = Campaign.find_by(is_master_template: true)
    
    unless master_campaign
      puts "❌ Master Campaign not found! Looking for campaign with is_master_template: true"
      exit 1
    end
    
    puts "\n⚠️  WARNING: This will remove ALL images from ALL weapons in the Master Campaign!"
    puts "   Campaign: #{master_campaign.name}"
    print "Are you sure? (type 'yes' to confirm): "
    
    confirmation = STDIN.gets.chomp
    unless confirmation.downcase == 'yes'
      puts "❌ Cancelled"
      exit 0
    end
    
    count = 0
    master_campaign.weapons.joins(:image_attachment).find_each do |weapon|
      weapon.image.purge
      count += 1
      print "." if count % 100 == 0
    end
    
    puts "\n✅ Removed images from #{count} weapons in Master Campaign"
  end
  
  desc "Attach a default image to all Master Campaign weapons without category-specific images"
  task attach_default_image: :environment do
    # Find the Master Campaign
    master_campaign = Campaign.find_by(is_master_template: true)
    
    unless master_campaign
      puts "❌ Master Campaign not found! Looking for campaign with is_master_template: true"
      exit 1
    end
    
    default_image_path = Rails.root.join('lib', 'assets', 'weapon_images', 'default.png')
    
    unless File.exist?(default_image_path)
      puts "❌ Default image not found: #{default_image_path}"
      puts "Note: Looking for default.png (not .jpg)"
      exit 1
    end
    
    weapons = master_campaign.weapons
                    .left_joins(:image_attachment)
                    .where(active_storage_attachments: { id: nil })
    
    count = weapons.count
    puts "Found #{count} weapons without images in Master Campaign"
    
    if count > 0
      print "Attaching default image"
      weapons.find_each.with_index do |weapon, index|
        weapon.image.attach(
          io: File.open(default_image_path),
          filename: "default_weapon_#{weapon.id}.png",
          content_type: 'image/png'
        )
        print "." if index % 10 == 0
      end
      puts " ✅"
      puts "Attached default image to #{count} weapons in Master Campaign"
    end
  end
end