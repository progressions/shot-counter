require 'rails_helper'

RSpec.describe User, type: :model do
  it "must have valid email" do
    @user = User.new(
      email: "alice@email.com",
      first_name: "Alice", 
      last_name: "Smith",
      password: "TestPass123!"
    )
    expect(@user).to be_valid
  end

  it "returns error with invalid email" do
    @user = User.new(
      email: "alice",
      first_name: "Alice",
      last_name: "Smith", 
      password: "TestPass123!"
    )
    expect(@user).not_to be_valid
    expect(@user.errors[:email]).to eq(["is invalid"])
  end

  describe "onboarding progress" do
    it "automatically creates onboarding progress on user creation" do
      user = User.create!(
        email: "test@example.com",
        first_name: "Test",
        last_name: "User",
        password: "TestPass123!"
      )
      
      expect(user.onboarding_progress).to be_present
      expect(user.onboarding_progress.user).to eq(user)
    end

    it "associates with onboarding progress" do
      user = User.create!(
        email: "test@example.com", 
        first_name: "Test",
        last_name: "User",
        password: "TestPass123!"
      )
      
      expect(user).to respond_to(:onboarding_progress)
      expect(user.onboarding_progress).to be_a(OnboardingProgress)
    end
  end
end
