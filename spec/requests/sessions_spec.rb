require 'rails_helper'

RSpec.describe 'Sessions', type: :request do
  describe 'GET /login' do
    it 'returns http success' do
      get login_path
      expect(response).to have_http_status :success
    end
  end
  describe 'DELETE /logout' do
    before do
      user = FactoryBot.create(:user)
      post login_path, params: { session: { email: user.email,
                                            password: user.password } }
    end
    it 'ログアウトできること' do
      expect(logged_in?).to be(true)

      delete logout_path
      expect(logged_in?).to_not be(true)
    end
    it '2回連続でログアウトしてもエラーにならないこと' do
      delete logout_path
      delete logout_path
      expect(response).to redirect_to root_path
    end
  end
  describe '#create' do
    it 'ユーザーがゼロの場合エラー画面を出さない' do
      expect(User.exists?(email: 'aaa@example.com')).to be(false)
      post login_path, params: { session: { email: 'aaa@example.com',
                                            password: 'foobar' } }
      expect(response).to render_template(:new)
    end

    describe 'remember me' do
      let(:user) { FactoryBot.create(:user) }
      it 'ONの場合はcookies[:remember_token]が空でないこと' do
        post login_path, params: { session: { email: user.email,
                                              password: user.password,
                                              remember_me: 1 } }
        expect(cookies[:remember_token]).to_not be_blank
      end

      it 'OFFの場合はcookies[:remember_token]が空であること' do
        post login_path, params: { session: { email: user.email,
                                              password: user.password,
                                              remember_me: 0 } }
        expect(cookies[:remember_token]).to be_blank
      end
    end
  end
end
