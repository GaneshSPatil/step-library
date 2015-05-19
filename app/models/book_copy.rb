class BookCopy < ActiveRecord::Base
  belongs_to :book
  has_many :records

  before_create :book_id_exists

  module Status
    AVAILABLE = 'Available'
    ISSUED = 'Issued'
  end

  def book_id_exists
    return false unless Book.find (self.book_id)
  end

  def issue user_id
    self.update_attribute(:status, BookCopy::Status::ISSUED)
    Record.create(user_id: user_id, book_copy_id: self.id, borrow_date: Date.today)
  end

  def return
    self.update_attribute(:status, BookCopy::Status::AVAILABLE)
  end
end
