class User < ActiveRecord::Base

  has_many :records
  devise :database_authenticatable,
         :omniauthable, :omniauth_providers => [:facebook]

  module Role
    ADMIN = 'Admin'
    INTERN = 'Intern'
  end

  def self.from_omniauth(auth, members)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      first = members.select { |member| member['id'] == auth['uid'] }.first
      user.role = first['administrator'] ? User::Role::ADMIN : User::Role::INTERN
      user.name = first['name']
      user.provider = auth.provider
      user.uid = auth.uid
      user.email = auth.info.email
    end
  end

  def self.search(search_param)
    User.select { |user| user.name.downcase.include?(search_param.downcase) }
  end

end