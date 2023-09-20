# == Schema Information
#
# Table name: microposts
#
#  id         :bigint           not null, primary key
#  content    :text
#  user_id    :bigint
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  picture    :string
#
FactoryBot.define do
  factory :micropost, class: Micropost do
    content { 'Hello' }
    created_at { 10.minutes.ago }
    user { association :user, email: 'recent@example.com' }

    trait :recent_post do
      content { 'I create this now' }
      created_at { Time.zone.now }
    end

    trait :post_by_user do
      content { 'Posted by User' }
      created_at { Time.zone.now }
    end

    trait :post_by_following_user do
      content { 'Posted by Following User' }
      created_at { Time.zone.now }
    end

    trait :post_by_unrelated_user do
      content { 'Posted by Unrelated User' }
      created_at { Time.zone.now }
    end
  end
end

def user_with_posts(posts_count: 5)
  FactoryBot.create(:user) do |user|
    FactoryBot.create_list(:micropost, posts_count, user: user)
  end
end
