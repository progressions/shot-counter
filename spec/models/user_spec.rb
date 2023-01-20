require 'rails_helper'

RSpec.describe User, type: :model do
  it "must have valid email" do
    @user = User.new(email: "alice@email.com")
    expect(@user).to be_valid
  end

  it "returns error with invalid email" do
    @user = User.new(email: "alice")
    expect(@user).not_to be_valid
    expect(@user.errors[:email]).to eq(["is invalid"])
  end
end
