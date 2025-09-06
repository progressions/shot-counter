# Skip loading ruby-vips in test environment to avoid CI issues
if Rails.env.test?
  # Prevent image processing from loading vips
  Rails.application.config.after_initialize do
    if defined?(ActiveStorage)
      # Disable image variants in test environment
      ActiveStorage.variant_processor = nil if ActiveStorage.respond_to?(:variant_processor=)
    end
  end
  
  # Mock the Vips module if anything tries to use it
  unless defined?(Vips)
    module Vips
      class Image
        def self.new_from_buffer(*args)
          raise "Vips is disabled in test environment"
        end
      end
    end
  end
end