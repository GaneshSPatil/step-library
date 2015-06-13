class Record < ActiveRecord::Base
  belongs_to :book_copy
  belongs_to :user

  def book_title
    self.book_copy.book.title
  end

  def book_copy_id
    self.book_copy.copy_id
  end

  def overdue?
    Time.now > expected_return_date
  end
end
