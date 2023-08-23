require 'rails_helper'
 
RSpec.describe User, type: :model do
  let(:user) { User.new(name: 'Example User', email: 'user@example.com') }
 
  it 'userが有効であること' do
    expect(user).to be_valid
  end

  it 'nameが必須であること' do
    user.name = ''
    expect(user).to_not be_valid
  end
end