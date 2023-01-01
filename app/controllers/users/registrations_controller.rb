# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  respond_to :json

  def create
    super
    resource.update(user_params)
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :avatar_url, :admin, :gamemaster)
  end

  def respond_with(resource, options={})
    if resource.persisted?
      render json: {
        status: { code: 200, message: 'Signed up successfully', data: resource }
      }
    else
      render json: {
        status: { message: 'User could not be created successfully', errors: resource.errors.full_messages }
      }, status: :unprocessable_entity
    end
  end
end
