FactoryGirl.define  do
  factory :user, class: User do |f|
    email "user@email.com"
    name "Pooja"
    role "Intern"
    encrypted_password ""
    provider "provider"
    enabled true
    uid "123"
  end

  trait :admin do
    role "Admin"
  end
end