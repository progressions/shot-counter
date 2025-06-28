class Api::V1::SuggestionsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign

  def index
    render json: [
      { id: "weapon", name: "Weapon" },
      { id: "armor", name: "Armor" },
      { id: "item", name: "Item" },
      { id: "spell", name: "Spell" },
      { id: "feat", name: "Feat" },
      { id: "class", name: "Class" },
    ]
  end

end
