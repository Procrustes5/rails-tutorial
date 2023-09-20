require 'rails_helper'

RSpec.describe 'Following', type: :system do
  before do
    driven_by(:rack_test)
    @user = FactoryBot.send(:create_relationships)
    log_in @user
  end
  describe 'following and followers' do

    context "フォロワーが多数いる場合" do
      it 'followingの数とフォローしているユーザへのリンクが表示されていること' do
        visit following_user_path(@user)
        expect(@user.following).to_not be_empty
        expect(page).to have_content '10 following'
        @user.following.each do |user|
          expect(page).to have_link user.name, href: user_path(user)
        end
      end
    end

    context 'フォロワーが複数ではない場合' do
      let(:user) { FactoryBot.create(:user, :unrelated) }
      let(:other) { FactoryBot.create(:user, :another) }
      it 'フォロワーがゼロの時は単数形で表示' do
        visit following_user_path(user)
        expect(user.following).to be_empty
        expect(page).to_not have_content 'followers'
      end

      it 'フォロワーが1名の時は単数形で表示' do
        FactoryBot.create(:follower, follower_id: other.id, followed_id: user.id)
        FactoryBot.create(:following, follower_id: user.id, followed_id: other.id)
        visit following_user_path(user)
        expect(user.following.count).to eq(1)
        expect(page).to_not have_content 'followers'
      end
    end
  end

  describe 'followers' do
    it 'followersの数とフォローしているユーザへのリンクが表示されていること' do
      visit followers_user_path(@user)
      expect(@user.followers).to_not be_empty
      expect(page).to have_content '10 followers'
      @user.followers.each do |user|
        expect(page).to have_link user.name, href: user_path(user)
      end
    end
  end
end
