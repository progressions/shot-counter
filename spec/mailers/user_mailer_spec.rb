require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  describe "password_reset" do
    let(:user) { User.create!(email: "email@example.com", password: "password", password_confirmation: "password", first_name: "John", last_name: "Doe") }
    let(:action_movie) { user.campaigns.create!(name: "Action Movie") }
    let(:invitation) { Invitation.create!(email: "someone@example.com", user: user, campaign: action_movie) }
    let(:mail) { UserMailer.with(invitation: invitation).invitation }

    it "renders the headers" do
      expect(mail.subject).to eq("You have been invited to join Action Movie in the Chi War!")
      expect(mail.to).to eq(["someone@example.com"])
      expect(mail.from).to eq(["admin@chiwar.net"])
    end
  end
end
