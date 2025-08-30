namespace :db do
  desc "Fix Active Storage blob sequence after import"
  task fix_blob_sequence: :environment do
    max_id = ActiveStorage::Blob.maximum(:id) || 0
    next_id = max_id + 1
    
    Rails.logger.info "Current max blob ID: #{max_id}"
    Rails.logger.info "Setting sequence to: #{next_id}"
    
    ActiveRecord::Base.connection.execute(
      "SELECT setval('active_storage_blobs_id_seq', #{next_id}, false)"
    )
    
    new_value = ActiveRecord::Base.connection.execute(
      "SELECT last_value FROM active_storage_blobs_id_seq"
    ).first['last_value']
    
    Rails.logger.info "Sequence now at: #{new_value}"
    puts "Active Storage blob sequence fixed. Next ID will be: #{next_id}"
  end
end