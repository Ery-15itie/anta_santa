FactoryBot.define do
  factory :github_profile do
    user { nil }
    access_token { "MyString" }
    refresh_token { "MyString" }
    expires_at { "2025-10-02 19:14:55" }
    followers_count { 1 }
    public_repos_count { 1 }
    total_private_repos_count { 1 }
  end
end
