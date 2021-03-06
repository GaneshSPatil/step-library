class BookCopy < ActiveRecord::Base
  belongs_to :book
  has_many :records

  before_create :book_id_exists

  module Status
    AVAILABLE = 'Available'
    ISSUED    = 'Issued'
    DISABLED  = 'Disabled'
  end

  def book_id_exists
    return false if Book.find_by_id(self.book_id).nil?
  end

  def issue user_id
    self.update_attribute(:status, BookCopy::Status::ISSUED)
    Record.create(user_id: user_id, book_copy_id: self.id, borrow_date: Time.now, expected_return_date: Time.now + book.return_days.days)
  end

  def return
    self.update_attribute(:status, BookCopy::Status::AVAILABLE)
  end

  def disable
    self.update_attribute(:status, BookCopy::Status::DISABLED)
  end
end
