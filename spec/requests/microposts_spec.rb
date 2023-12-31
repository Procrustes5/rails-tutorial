require 'rails_helper'

RSpec.describe 'Microposts', type: :request do
  describe '#create' do
    context '未ログインの場合' do
      it '登録されないこと' do
        expect do
          post microposts_path, params: { micropost: { content: 'Lorem ipsum' } }
        end.to_not change(Micropost, :count)
      end

      it 'ログインページにリダイレクトされること' do
        post microposts_path, params: { micropost: { content: 'Lorem ipsum' } }
        expect(response).to redirect_to login_path
      end
    end
  end

  describe '#destroy' do
    let(:user) { FactoryBot.create(:user) }

    before do
      @post = FactoryBot.create(:micropost, :recent_post)
    end

    context '他のユーザの投稿を削除した場合' do
      before do
        log_in user
      end

      it '削除されないこと' do
        expect do
          delete micropost_path(@post)
        end.to_not change(Micropost, :count)
      end

      it 'ホームページにリダイレクトされること' do
        delete micropost_path(@post)
        expect(response).to redirect_to root_path
      end
    end

    context '未ログインの場合' do
      it '削除されないこと' do
        expect do
          delete micropost_path(@post)
        end.to_not change(Micropost, :count)
      end

      it 'ログインページにリダイレクトされること' do
        delete micropost_path(@post)
        expect(response).to redirect_to login_path
      end
    end
  end
end
