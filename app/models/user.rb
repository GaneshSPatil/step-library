class User < ActiveRecord::Base
  devise :database_authenticatable,
         :omniauthable, :omniauth_providers => [:facebook]

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.email = auth.info.email
      user.role = auth.role
    end
  end
  module Role
    ADMIN = 'Admin'
    INTERN = 'Intern'
  end
end