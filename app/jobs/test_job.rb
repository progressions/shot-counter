class TestJob < ApplicationJob
  queue_as :default

  def perform(message = "Test")
    Rails.logger.info "[TestJob] EXECUTING - Message: #{message} at #{Time.current}"
    puts "[TestJob] EXECUTING - Message: #{message} at #{Time.current}"
  end
end