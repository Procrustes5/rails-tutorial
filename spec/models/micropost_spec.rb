# == Schema Information
#
# Table name: microposts
#
#  id         :bigint           not null, primary key
#  content    :text             not null
#  user_id    :bigint           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  picture    :string
#
require 'rails_helper'

RSpec.describe Micropost, type: :model do
  it '有効であること' do
    micropost = Micropost.new
    micropost.user = User.first
    micropost.content = '1234'
    expect(micropost).to be_valid
  end

  let(:micropost) { FactoryBot.create(:micropost) }
  let(:recent_post) { FactoryBot.create(:micropost, :recent_post) }

  it 'user_idが存在する' do
    micropost.user_id = nil
    expect(micropost).to_not be_valid
  end

  it '最新順で並べること' do
    FactoryBot.send(:user_with_posts)
    expect(recent_post).to eq Micropost.first
  end

  it 'ユーザーを破棄するとポストも破棄する' do
    post = FactoryBot.create(:micropost, :recent_post)
    user = post.user
    expect do
      user.destroy
    end.to change(Micropost, :count).by(-1)
  end

  describe 'content' do
    it '内容が空なら無効であること' do
      micropost.content = '    '
      expect(micropost).to_not be_valid
    end

    it '内容は140字までにする' do
      micropost.content = 'a' * 141
      expect(micropost).to_not be_valid
    end
  end
end
