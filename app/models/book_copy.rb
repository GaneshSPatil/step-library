class BookCopy < ActiveRecord::Base
  belongs_to :book

  before_create :book_id_exists

  def book_id_exists
    return false if Book.find_by_id(self.book_id).nil?
  end
end
