class User < ActiveRecord::Base

  has_many :records
  devise :database_authenticatable,
         :omniauthable, :omniauth_providers => [:facebook]

  module Role
    ADMIN  = 'Admin'
    INTERN = 'Intern'
  end

  def self.from_omniauth(auth, members)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      first         = members.select { |member| member['id'] == auth['uid'] }.first
      user.role     = first['administrator'] ? User::Role::ADMIN : User::Role::INTERN
      user.name     = first['name']
      user.provider = auth.provider
      user.uid      = auth.uid
      user.email    = auth.info.email
    end
  end

  def self.search(search_param)
    User.where('name LIKE ?', '%' + search_param + '%').where(enabled: true)
  end

  def book_copies
    Record.includes(:book_copy).where(user_id: self.id, return_date: nil).map(&:book_copy)
  end

  def books
    # here it joining tables Record, Book, BookCopy.
    Record.includes(book_copy: :book).where(user_id: self.id, return_date: nil).map(&:book_copy).map(&:book)
  end

  def has_book? book
    books.include?(book)
  end

  def return_book book_copy_id
    record = Record.where(book_copy_id: book_copy_id, user_id: self.id, return_date: nil).first
    record.update_attributes(return_date: Time.now)
    record.book_copy.return
  end

  def disable user_id
    user = User.find user_id
    user.update_attributes(enabled: false)
  end


  def self.is_disabled auth
    users = User.where(uid: auth.uid)
    users.size > 0 ? (!users.first.enabled) : false
  end

end