# == Schema Information
#
# Table name: microposts
#
#  id         :bigint           not null, primary key
#  content    :text
#  user_id    :bigint
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'rails_helper'

RSpec.describe Micropost, type: :model do
  let(:user) { FactoryBot.create(:user) }
  let(:micropost) { user.microposts.build(content: "Lorem ipsum") }

  it '有効であること' do
    expect(micropost).to be_valid
  end

  it 'user_idが存在する' do
    micropost.user_id = nil
    expect(micropost).to_not be_valid
  end

  describe "content" do
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
