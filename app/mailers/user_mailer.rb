class UserMailer < Devise::Mailer
  # helper :application
  include Devise::Controllers::UrlHelpers # Optional. eg. `confirmation_url`
  # default template_path: 'devise/mailer' # to make sure that your mailer uses the devise views
  # If there is an object in your application that returns a contact email, you can use it as follows
  # Note that Devise passes a Devise::Mailer object to your proc, hence the parameter throwaway (*).
  # default from: ->(*) { Class.instance.email_address }

  default from: ->(*) { "admin@chiwar.net" }

  def welcome
    @user = params[:user]
    mail(to: @user.email, subject: "Welcome to the Chi War!")
  end

  def invitation
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

  def joined_campaign
    @user = params[:user]
    @campaign = params[:campaign]

    mail(to: @user.email, subject: "You have joined the campaign: #{Wcampaign.name}")
  end

  def removed_from_campaign
    @user = params[:user]
    @campaign = params[:campaign]

    mail(to: @user.email, subject: "You have been removed from the campaign: #{Wcampaign.name}")
  end

  def confirmation_instructions(record, token, opts={})
    @user = record
    @token = token
    
    # Check if this user has a pending invitation
    if @user.pending_invitation_id
      @invitation = Invitation.find_by(id: @user.pending_invitation_id)
      @campaign = @invitation&.campaign
      
      subject = if @campaign
        "Confirm your account to join #{@campaign.name} in the Chi War!"
      else
        "Confirm your account - Welcome to the Chi War!"
      end
    else
      subject = "Confirm your account - Welcome to the Chi War!"
    end
    
    # Set up the frontend URL for confirmation
    if Rails.application.config.action_mailer.default_url_options
      host = Rails.application.config.action_mailer.default_url_options[:host]
      protocol = Rails.application.config.action_mailer.default_url_options[:protocol]
      port = Rails.application.config.action_mailer.default_url_options[:port]
      port = ":#{port}" if port
      @root_url = "#{protocol}://#{host}#{port}"
      
      # Use frontend URL for confirmation (port 3001)
      frontend_host = host
      frontend_port = Rails.env.development? ? ":3001" : port
      @frontend_confirmation_url = "#{protocol}://#{frontend_host}#{frontend_port}/confirm?confirmation_token=#{@token}"
    else
      # Fallback for development
      @frontend_confirmation_url = "http://localhost:3001/confirm?confirmation_token=#{@token}"
    end
    
    mail(to: @user.email, subject: subject)
  end

  def reset_password_instructions(record, token, opts={})
    @user = record
    @token = token
    
    # Set up the frontend URL for password reset
    if Rails.application.config.action_mailer.default_url_options
      host = Rails.application.config.action_mailer.default_url_options[:host]
      protocol = Rails.application.config.action_mailer.default_url_options[:protocol]
      port = Rails.application.config.action_mailer.default_url_options[:port]
      port = ":#{port}" if port
      @root_url = "#{protocol}://#{host}#{port}"
      
      # Use frontend URL for password reset (port 3001)
      frontend_host = host
      frontend_port = Rails.env.development? ? ":3001" : port
      @frontend_reset_url = "#{protocol}://#{frontend_host}#{frontend_port}/reset-password/#{@token}"
    else
      # Fallback for development
      @frontend_reset_url = "http://localhost:3001/reset-password/#{@token}"
    end
    
    # Add security headers
    headers['X-Auto-Response-Suppress'] = 'OOF, AutoReply'
    headers['X-Mailer'] = 'Chi War Password Reset System'
    
    mail(
      to: @user.email,
      subject: "Reset your Chi War password",
      template_name: 'reset_password_instructions'
    )
  end

end
