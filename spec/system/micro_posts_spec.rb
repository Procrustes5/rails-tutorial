require 'rails_helper'

RSpec.describe 'MicroPosts', type: :system do
  before do
    driven_by(:rack_test)
  end

  describe 'Users#show' do
    before do
      FactoryBot.send(:user_with_posts, posts_count: 35)
      @user = Micropost.first.user
    end

    it '30件表示されていること' do
      visit user_path @user

      posts_wrapper =
        within 'ol.microposts' do
          find_all('li')
        end
      expect(posts_wrapper.size).to eq 30
    end

    it 'ページネーションのラッパータグが表示されていること' do
      visit user_path @user
      expect(page).to have_selector 'div.pagination'
    end

    it 'Micropostの本文がページ内に表示されていること' do
      visit user_path @user
      @user.microposts.paginate(page: 1).each do |micropost|
        expect(page).to have_content micropost.content
      end
    end

    it 'ページネーションの表示が1箇所のみであること' do
      visit user_path @user
      pagination = find_all('div.pagination')
      expect(pagination.size).to eq 1
    end
  end
  describe 'home' do
    before do
      FactoryBot.send(:user_with_posts, posts_count: 35)
      @user = Micropost.first.user
      @user.password = 'password'
      log_in @user
      visit root_path
    end

    it 'ページネーションのラッパータグがあること' do
      expect(page).to have_selector 'div.pagination'
    end

    it '画像添付ができること' do
      expect do
        fill_in 'micropost_content', with: 'hello'
        attach_file 'micropost[picture]', Rails.root.join('spec/factories/rails.png').to_s
        click_button 'Post'
      end.to change(Micropost, :count).by 1

      attached_post = Micropost.first
      expect(attached_post.picture).to_not be(false)
    end

    context '有効な送信の場合' do
      it '投稿されること' do
        expect do
          fill_in 'micropost_content', with: 'This micropost really ties the room together'
          click_button 'Post'
        end.to change(Micropost, :count).by 1

        expect(page).to have_content 'This micropost really ties the room together'
      end
    end

    context '無効な送信の場合' do
      it 'contentが空なら投稿されないこと' do
        fill_in 'micropost_content', with: ''
        click_button 'Post'

        expect(page).to have_selector 'div#error_explanation'
      end
    end

    describe '削除機能' do
      it 'deleteボタンが表示されていること' do
        expect(page).to have_link 'delete'

        fill_in 'micropost_content', with: 'This micropost really ties the room together'
        click_button 'Post'

        post = Micropost.first

        expect do
          click_link 'delete', href: micropost_path(post)
        end.to change(Micropost, :count).by(-1)
        expect(page).to_not have_content 'This micropost really ties the room together'
      end

      it '他のユーザのプロフィールではdeleteボタンが表示されないこと' do
        @other_user = FactoryBot.create(:user, :another)
        visit user_path(@other_user)
        expect(page).to_not have_link 'delete'
      end
    end

    it '投稿数が"n microposts"と表示されること' do
      posts = @user.microposts.count.to_s
      expect(page).to have_content "#{posts} microposts"
    end

    it '0件なら"0 microposts"、1件なら"1 micropost"と表示されること' do
      @user.microposts.destroy_all
      visit current_path
      expect(page).to have_content '0 microposts'

      fill_in 'micropost_content', with: 'test post'
      click_button 'Post'
      expect(page).to have_content '1 micropost'
    end
  end
end
