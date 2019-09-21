FactoryBot.define do
  factory :check_in do
    user { create(:user) }
    begin_time { Time.current }
  end
end
