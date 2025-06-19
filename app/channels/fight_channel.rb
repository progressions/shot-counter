class FightChannel < ApplicationCable::Channel
  def subscribed
    puts "Subscribing to fight_#{params[:fight_id]}"
    stream_from "fight_#{params[:fight_id]}"
    puts "Subscribed successfully to fight_#{params[:fight_id]}"
  end

  def unsubscribed
    puts "Unsubscribed from fight_#{params[:fight_id]}"
  end
end
