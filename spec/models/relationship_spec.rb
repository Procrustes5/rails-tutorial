# == Schema Information
#
# Table name: relationships
#
#  id          :bigint           not null, primary key
#  follower_id :integer
#  followed_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
require 'rails_helper'

RSpec.describe Relationship, type: :model do
  let(:user) { FactoryBot.create(:user)}
  let(:other_user) { FactoryBot.create(:user, :another)}
  before do
    @relationship = Relationship.new(follower_id: user.id, followed_id: other_user.id)
  end

  it "Relationshipモデルが有効であること" do
    expect(@relationship).to be_valid
  end

  it "follower_idが必須であること" do
    @relationship.follower_id = nil
    expect(@relationship).to_not be_valid
  end

  it "followed_idが必須であること" do
    @relationship.followed_id = nil
    expect(@relationship).to_not be_valid
  end
  let(:unrelated_user) { FactoryBot.create(:user, :unrelated) }
  it "followとunfollowができること" do
    expect(user.following?(unrelated_user)).to be(false)
    user.follow(unrelated_user)
    expect(user.following?(unrelated_user)).to be(true)
    user.unfollow(unrelated_user)
    expect(user.following?(unrelated_user)).to be(false)
  end
end
