require 'rails_helper'

RSpec.describe 'Users', type: :request do
  describe 'GET /signup' do
    it 'returns http success' do
      get signup_path
      expect(response).to have_http_status(:ok)
    end
    it 'Sign up | Ruby on Rails Tutorial Sample Appが含まれること' do
      get signup_path
      expect(response.body).to include full_title('Sign up')
    end
  end
  context '有効な値の場合' do
    let(:user_params) do
      { user: { name: 'Example User',
                email: 'user@example.com',
                password: 'password',
                password_confirmation: 'password' } }
    end

    it '登録されること' do
      expect do
        post users_path, params: user_params
      end.to change(User, :count).by 1
    end

    it 'users/showにリダイレクトされること' do
      post users_path, params: user_params
      user = User.last
      expect(response).to redirect_to user
    end
    it 'flashが表示されること' do
      post users_path, params: user_params
      expect(flash).to be_any
    end
    it 'ログイン状態であること' do
      post users_path, params: user_params
      expect(logged_in?).to be(true)
    end
  end
  describe 'PATCH /users' do
    let!(:user) { FactoryBot.create(:user) }
 
    it 'タイトルがEdit user | Ruby on Rails Tutorial Sample Appであること' do
      get edit_user_path(user)
      expect(response.body).to include full_title('Edit user')
    end
 
    context '無効な値の場合' do
      it '更新できないこと' do
        patch user_path(user), params: { user: { name: '',
                                                 email: 'foo@invlid',
                                                 password: 'foo',
                                                 password_confirmation: 'bar' } }
        user.reload
        expect(user.name).to_not eq ''
        expect(user.email).to_not eq ''
        expect(user.password).to_not eq 'foo'
        expect(user.password_confirmation).to_not eq 'bar'
      end
 
      it '更新アクション後にeditのページが表示されていること' do
        get edit_user_path(user)
        patch user_path(user), params: { user: { name: '',
                                                 email: 'foo@invlid',
                                                 password: 'foo',
                                                 password_confirmation: 'bar' } }
        expect(response.body).to include full_title('Edit user')
      end

      it 'The form contains 4 errors.と表示されていること' do
        patch user_path(user), params: { user: { name: '',
                                                 email: 'foo@invlid',
                                                 password: 'foo',
                                                 password_confirmation: 'bar' } }
        expect(response.body).to include 'The form contains 4 errors.'
      end
    end
    context '有効な値の場合' do
      before do
        @name = 'Foo Bar'
        @email = 'foo@bar.com'
        patch user_path(user), params: { user: { name: @name,
                                                 email: @email,
                                                 password: '',
                                                 password_confirmation: '' } }
      end
    
      it '更新できること' do
        user.reload
        expect(user.name).to eq @name
        expect(user.email).to eq @email
      end
   
      it 'Users#showにリダイレクトすること' do
        expect(response).to redirect_to user
      end
   
      it 'flashが表示されていること' do
        expect(flash).to be_any
      end
    end
  end
end
