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

    it 'homeにリダイレクトされること' do
      post users_path, params: user_params
      expect(response).to redirect_to root_path
    end
    it 'flashが表示されること' do
      post users_path, params: user_params
      expect(flash).to be_any
    end
  end

  describe 'get /users/{id}/edit' do
    let(:user) { FactoryBot.create(:user) }

    it 'タイトルがEdit user | Ruby on Rails Tutorial Sample Appであること' do
      log_in user
      get edit_user_path(user)
      expect(response.body).to include full_title('Edit user')
    end

    context '未ログインの場合' do
      it 'flashが空でないこと' do
        get edit_user_path(user)
        expect(flash).to_not be_empty
      end

      it '未ログインユーザはログインページにリダイレクトされること' do
        get edit_user_path(user)
        expect(response).to redirect_to login_path
      end

      it 'ログインすると編集ページにリダイレクトされること' do
        get edit_user_path(user)
        log_in user
        expect(response).to redirect_to edit_user_path(user)
      end
    end

    context '別のユーザの場合' do
      let(:other_user) { FactoryBot.create(:user, :another) }

      it 'flashが空であること' do
        log_in user
        get edit_user_path(other_user)
        expect(flash).to be_empty
      end

      it 'root_pathにリダイレクトされること' do
        log_in user
        get edit_user_path(other_user)
        expect(response).to redirect_to root_path
      end
    end
  end
  describe 'PATCH /users' do
    let(:user) { FactoryBot.create(:user) }

    context '無効な値の場合' do
      before do
        log_in user
        patch user_path(user), params: { user: { name: '',
                                                 email: 'foo@invlid',
                                                 password: 'foo',
                                                 password_confirmation: 'bar' } }
      end

      it '更新できないこと' do
        user.reload
        expect(user.name).to_not eq ''
        expect(user.email).to_not eq ''
        expect(user.password).to_not eq 'foo'
        expect(user.password_confirmation).to_not eq 'bar'
      end

      it '更新アクション後にeditのページが表示されていること' do
        expect(response.body).to include full_title('Edit user')
      end

      it 'The form contains 4 errors.と表示されていること' do
        expect(response.body).to include 'The form contains 4 errors.'
      end
    end

    context '未ログインの場合' do
      it 'flashが空でないこと' do
        patch user_path(user), params: { user: { name: user.name,
                                                 email: user.email } }
        expect(flash).to_not be_empty
      end

      it '未ログインユーザはログインページにリダイレクトされること' do
        patch user_path(user), params: { user: { name: user.name,
                                                 email: user.email } }
        expect(response).to redirect_to login_path
      end
    end
    context '別のユーザの場合' do
      let(:other_user) { FactoryBot.create(:user, :another) }

      before do
        log_in user
        patch user_path(other_user), params: { user: { name: other_user.name,
                                                       email: other_user.email } }
      end

      it 'flashが空であること' do
        expect(flash).to be_empty
      end

      it 'rootにリダイレクトすること' do
        expect(response).to redirect_to root_path
      end
    end
  end

  describe 'GET /users' do
    it 'ログインユーザでなければログインページにリダイレクトすること' do
      get users_path
      expect(response).to redirect_to login_path
    end
  end

  describe 'show' do
    it '有効化されていないユーザの場合はrootにリダイレクトすること' do
      user = FactoryBot.create(:user)
      not_activated_user = FactoryBot.create(:user, :not_activated)

      log_in user
      get user_path(not_activated_user)
      expect(response).to redirect_to root_path
    end
  end

  describe 'index' do
    let(:user) { FactoryBot.create(:user) }

    describe 'pagination' do
      before do
        30.times do
          FactoryBot.create(:continuous_users)
        end
        log_in user
        get users_path
      end

      it 'div.paginationが存在すること' do
        expect(response.body).to include '<div class="pagination">'
      end

      it 'ユーザごとのリンクが存在すること' do
        User.paginate(page: 1).each do |user|
          expect(response.body).to include "<a href=\"#{user_path(user)}\">"
        end
      end
      it 'activateされていないユーザは表示されないこと' do
        not_activated_user = FactoryBot.create(:user, :not_activated)
        log_in user
        get users_path
        expect(response.body).to_not include not_activated_user.name
      end
    end
  end
  describe 'PATCH /users' do
    let(:user) { FactoryBot.create(:user) }

    it 'admin属性は更新できないこと' do
      log_in user = FactoryBot.create(:user)
      expect(user).to_not be_admin

      patch user_path(user), params: { user: { password: 'password',
                                               password_confirmation: 'password',
                                               admin: true } }
      user.reload
      expect(user).to_not be_admin
    end
  end

  describe 'DELETE /users/{id}' do
    let!(:user) { FactoryBot.create(:user, :admin) }
    let!(:other_user) { FactoryBot.create(:user, :another) }

    context 'adminユーザでログイン済みの場合' do
      it '削除できること' do
        log_in user
        expect do
          delete user_path(other_user)
        end.to change(User, :count).by(-1)
      end
    end

    context '未ログインの場合' do
      it '削除できないこと' do
        expect do
          delete user_path(user)
        end.to_not change(User, :count)
      end

      it 'ログインページにリダイレクトすること' do
        delete user_path(user)
        expect(response).to redirect_to login_path
      end
    end

    context 'adminユーザでない場合' do
      it '削除できないこと' do
        log_in other_user
        expect do
          delete user_path(user)
        end.to_not change(User, :count)
      end

      it 'rootにリダイレクトすること' do
        log_in other_user
        delete user_path(user)
        expect(response).to redirect_to root_path
      end
    end
  end

  describe 'GET /users/{id}/following' do
    let(:user) { FactoryBot.create(:user) }

    it '未ログインならログインページにリダイレクトすること' do
      get following_user_path(user)
      expect(response).to redirect_to login_path
    end
  end

  describe 'GET /users/{id}/followers' do
    let(:user) { FactoryBot.create(:user) }

    it '未ログインならログインページにリダイレクトすること' do
      get followers_user_path(user)
      expect(response).to redirect_to login_path
    end
  end
end
