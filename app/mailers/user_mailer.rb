class UserMailer < Devise::Mailer
  # helper :application
  include Devise::Controllers::UrlHelpers # Optional. eg. `confirmation_url`
  # default template_path: 'devise/mailer' # to make sure that your mailer uses the devise views
  # If there is an object in your application that returns a contact email, you can use it as follows
  # Note that Devise passes a Devise::Mailer object to your proc, hence the parameter throwaway (*).
  # default from: ->(*) { Class.instance.email_address }

  default from: ->(*) { "admin@chiwar.net" }

  def welcome(params)
    @user = params[:user]
    mail(to: @user.email, subject: "Welcome to the Chi War!")
  end

  def invitation(params)
    @invitation = params[:invitation]
    @campaign = @invitation.campaign
    if Rails.application.config.action_mailer.default_url_options
      host = Rails.application.config.action_mailer.default_url_options[:host]
      protocol = Rails.application.config.action_mailer.default_url_options[:protocol]
      port = Rails.application.config.action_mailer.default_url_options[:port]
      port = ":#{port}" if port
      @root_url = "#{protocol}://#{host}#{port}"
    end
    mail(to: @invitation.email, subject: "You have been invited to join #{@invitation.campaign.name} in the Chi War!")
  end

end
