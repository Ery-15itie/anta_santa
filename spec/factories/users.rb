FactoryBot.define do
  factory :user do
    # ユニークな名前とメアドを自動生成
    sequence(:username) { |n| "santa_user_#{n}" }
    sequence(:email) { |n| "santa#{n}@example.com" }
    password { 'password' }
    password_confirmation { 'password' }
  end
end
