FactoryGirl.define  do
  factory :user, class: User do |f|
    email "user@email.com"
    name "Pooja"
    role "Intern"
    encrypted_password ""
    reset_password_token ""
    current_sign_in_at Time.now
    provider "provider"
  end

  trait :admin do
    role "Admin"
  end
end