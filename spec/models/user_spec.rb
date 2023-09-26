# == Schema Information
#
# Table name: users
#
#  id                :bigint           not null, primary key
#  name              :string           not null
#  email             :string           not null
#  password_digest   :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  remember_digest   :string
#  admin             :boolean          default(FALSE), not null
#  activation_digest :string
#  activated         :boolean          default(FALSE), not null
#  activated_at      :datetime
#  reset_digest      :string
#  reset_sent_at     :datetime
#
require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { FactoryBot.create(:user) }

  it 'userが有効であること' do
    expect(user).to be_valid
  end

  it 'nameが必須であること' do
    user.name = ''
    expect(user).to_not be_valid
  end
  it 'emailが必須であること' do
    user.email = ''
    expect(user).to_not be_valid
  end
  it 'nameは50文字以内であること' do
    user.name = 'a' * 51
    expect(user).to_not be_valid
  end

  it 'emailは255文字以内であること' do
    user.email = "#{'a' * 244}@example.com"
    expect(user).to_not be_valid
  end

  it 'emailが有効な形式であること' do
    valid_addresses = %w[user@exmple.com USER@foo.COM A_US-ER@foo.bar.org first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      user.email = valid_address
      expect(user).to be_valid
    end
  end
  it '無効な形式のemailは失敗すること' do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example. foo@bar_baz.com foo@bar+baz.com]
    invalid_addresses.each do |invalid_address|
      user.email = invalid_address
      expect(user).to_not be_valid
    end
  end
  it 'emailは重複して登録できないこと' do
    duplicate_user = user.dup
    user.save
    expect(duplicate_user).to_not be_valid
  end
  it 'emailは重複して登録できないこと' do
    duplicate_user = user.dup
    duplicate_user.email = user.email.upcase
    user.save
    expect(duplicate_user).to_not be_valid
  end
  it 'emailは小文字でDB登録されていること' do
    mixed_case_email = 'Foo@ExAMPle.CoM'
    user.email = mixed_case_email
    user.save
    expect(user.reload.email).to eq mixed_case_email.downcase
  end
  it 'passwordが必須であること' do
    user.password = user.password_confirmation = ' ' * 6
    expect(user).to_not be_valid
  end

  it 'passwordは6文字以上であること' do
    user.password = user.password_confirmation = 'a' * 5
    expect(user).to_not be_valid
  end

  describe '#authenticated?' do
    it 'remember_digestがnilならfalseを返すこと' do
      expect(user.authenticated?('remember', nil)).to be(false)
    end
  end

  describe '#feed' do
    let(:posted_by_user) { FactoryBot.create(:micropost, :post_by_user) }
    let(:posted_by_following_user) { FactoryBot.create(:micropost, :post_by_following_user) }
    let(:posted_by_unrelated_user) { FactoryBot.create(:micropost, :post_by_unrelated_user) }
    let(:user) { FactoryBot.create(:user) }
    let(:following_user) { FactoryBot.create(:user, :another) }
    let(:unrelated_user) { FactoryBot.create(:user, :unrelated) }

    before do
      user.follow!(following_user)
    end

    it 'フォローしているユーザの投稿が表示されること' do
      following_user.microposts.each do |post_following|
        expect(user.feed.include?(post_following)).to be(true)
      end
    end

    it '自分自身の投稿が表示されること' do
      user.microposts.each do |post_self|
        expect(user.feed.include?(post_self)).to be(true)
      end
    end

    it 'フォローしていないユーザの投稿は表示されないこと' do
      unrelated_user.microposts.each do |post_unfollowed|
        expect(user.feed.include?(post_unfollowed)).to be(false)
      end
    end
  end
end
