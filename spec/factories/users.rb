FactoryGirl.define do
  factory :user do
    name  "Test User"
    email "sample@example.com"
    password              "foobartest"
    password_confirmation "foobartest"
    activated    true
    activated_at Time.zone.now
  end
end