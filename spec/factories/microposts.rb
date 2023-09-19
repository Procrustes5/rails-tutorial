FactoryBot.define do
  factory :micropost, class: Micropost do
    content { 'Hello' }
    created_at { 10.minutes.ago }
    user { association :user, email: 'recent@example.com' }

    trait :recent_post do
      content { 'I create this now' }
      created_at { Time.zone.now }
    end
  end
end

def user_with_posts(posts_count: 5)
  FactoryBot.create(:user) do |user|
    FactoryBot.create_list(:micropost, posts_count, user: user)
  end
end