# == Schema Information
#
# Table name: users
#
#  id                :bigint           not null, primary key
#  name              :string           not null
#  email             :string           not null
#  password_digest   :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  remember_digest   :string
#  admin             :boolean          default(FALSE), not null
#  activation_digest :string
#  activated         :boolean          default(FALSE), not null
#  activated_at      :datetime
#  reset_digest      :string
#  reset_sent_at     :datetime
#
FactoryBot.define do
  factory :user do
    name { 'Michael Example' }
    email { 'michael@example.com' }
    password { 'password' }
    password_confirmation { 'password' }
    admin { false }
    activated { true }
    activated_at { Time.zone.now }

    trait :admin do
      email { 'admin@admin.com' }
      admin { true }
    end

    trait :not_activated do
      name { 'Sterling Arche' }
      email { 'duchess@example.go' }
      activated { false }
      activated_at { nil }
    end

    trait :another do
      name { 'Sterling Archer' }
      email { 'duchess@example.gov' }
    end

    trait :unrelated do
      name { 'Sterling Arch' }
      email { 'duchess@example.com' }
    end
  end

  factory :continuous_users, class: User do
    sequence(:name) { |n| "User #{n}" }
    sequence(:email) { |n| "user-#{n}@example.com" }
    password { 'password' }
    password_confirmation { 'password' }
    activated { true }
    activated_at { Time.zone.now }
  end
end
