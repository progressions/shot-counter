class Api::V1::NotionController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_campaign

  def characters
    name = params[:name]

    page = notion.find_page_by_name(name)

    if page.present?
      render json: page
    end
  end

  private

  def notion
    @notion ||= NotionService
  end
end
