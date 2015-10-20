FactoryGirl.define do
  factory :user do
    sequence(:name)  { |n| "Person #{n}" }
    sequence(:email) { |n| "person_#{n}@example.com"}
    password "foobar"
    password_confirmation "foobar"

    factory :admin do
      admin true
    end
  end

  factory :micropost do
    content "Lorem ipsum"
    user
  end

  factory :userToReplyTo, class: User do | user |
    user.name "Donald Duck"
    user.email "donald@entenhausen.de"
    user.password "foobar"
    user.password_confirmation "foobar"
  end

  factory :micropost_to_donald do |micropost|
    micropost.content "@Donald_Duck bla bla bla"
    micropost.association :user
  end
end
