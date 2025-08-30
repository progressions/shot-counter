# Sidekiq configuration for connection pooling
require 'sidekiq'

# Sidekiq server configuration (worker process)
Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0') }
  
  # Configure database connection pool for Sidekiq workers
  # This ensures workers have sufficient connections for heavy operations
  config.on(:startup) do
    ActiveRecord::Base.connection_pool.disconnect!
    
    ActiveSupport.on_load(:active_record) do
      db_config = ActiveRecord::Base.configurations.configs_for(env_name: Rails.env).first
      db_config_hash = db_config.configuration_hash.merge(
        pool: ENV.fetch("SIDEKIQ_DB_POOL", 10).to_i,
        checkout_timeout: 10,
        reaping_frequency: 10
      )
      ActiveRecord::Base.establish_connection(db_config_hash)
    end
  end
end

# Sidekiq client configuration (web process)
Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0') }
end

# Sidekiq retry configuration
Sidekiq.default_job_options = {
  retry: 3,
  backtrace: true
}
