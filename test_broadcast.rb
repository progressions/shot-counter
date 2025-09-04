require_relative 'config/environment'

fight = Fight.first
$count = 0

class Fight
  alias_method :original_broadcast, :broadcast_encounter_update!
  def broadcast_encounter_update!
    $count += 1
    puts "Broadcast #{$count}: disable_broadcasts=#{Thread.current[:disable_broadcasts]}"
    puts "  Called from: #{caller[0]}"
    original_broadcast
  end
end

puts "Starting test..."
ActiveRecord::Base.transaction do
  Thread.current[:disable_broadcasts] = true
  fight.touch
  Thread.current[:disable_broadcasts] = false
end
fight.broadcast_encounter_update!
puts "Total broadcasts: #{$count}"
