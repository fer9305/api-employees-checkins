FactoryBot.define do
  factory :user do
    first_name { FFaker::Name.first_name }
    last_name  { FFaker::Name.last_name }
    password  { FFaker::Internet.password }
    email  { FFaker::Internet.email }
    role { 'admin' }
    gender { 'male' }
    birthday { Time.current - 25.years }

    trait :employee do
      role { 'employee' }
    end
  end
end