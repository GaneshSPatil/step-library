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
    User.where('name LIKE ?', '%' + search_param + '%').where(enabled: true).order(:name)
  end

  def records
    Record.includes(:book_copy).where(user_id: self.id, return_date: nil)
  end

  def books
    # here it joining tables Record, Book, BookCopy.
    Record.includes(book_copy: :book).where(user_id: self.id, return_date: nil).map(&:book_copy).map(&:book)
  end

  def issued_books_records
    # need records in order to get issued_date of particular book_copy
    Record.includes(book_copy: :book).where(user_id: self.id, return_date: nil)
  end

  def has_book? book
    books.include?(book)
  end

  def return_book book_copy_id
    record = Record.where(book_copy_id: book_copy_id, user_id: self.id, return_date: nil).first
    record.update_attributes(return_date: Time.now)
    record.book_copy.return
  end

  def disable
    update(enabled: false)
  end


  def self.is_disabled auth
    user=User.where(uid: auth.uid).first
    user.nil? ? false : !user.enabled
  end

  def self.disabled search_param
    User.where(enabled: false).order(:name).select{ |user| user.name.downcase.include?(search_param.downcase) }
  end

  def logs
    Record.includes(book_copy: :book).where(user_id: self.id).order(:borrow_date).reverse
  end
end