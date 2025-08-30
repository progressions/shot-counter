namespace :db do
  desc "Fix Active Storage blob and attachment sequences after import"
  task fix_blob_sequence: :environment do
    ['active_storage_blobs', 'active_storage_attachments'].each do |table|
      max_id = ActiveRecord::Base.connection.execute(
        "SELECT MAX(id) FROM #{table}"
      ).first['max'].to_i
      
      next_id = max_id + 1
      
      Rails.logger.info "#{table}: Current max ID: #{max_id}"
      Rails.logger.info "#{table}: Setting sequence to: #{next_id}"
      
      ActiveRecord::Base.connection.execute(
        "SELECT setval('#{table}_id_seq', #{next_id}, false)"
      )
      
      new_value = ActiveRecord::Base.connection.execute(
        "SELECT last_value FROM #{table}_id_seq"
      ).first['last_value']
      
      Rails.logger.info "#{table}: Sequence now at: #{new_value}"
      puts "#{table} sequence fixed. Next ID will be: #{next_id}"
    end
  end
end