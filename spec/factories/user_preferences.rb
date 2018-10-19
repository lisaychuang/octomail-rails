FactoryBot.define do
  factory :user_preference do
    user { nil }
    search_input { "MyString" }
    repos { "MyString" }
  end
end
