class BookCopy < ActiveRecord::Base
  belongs_to :book
  has_many :records

  before_create :book_id_exists

  module Status
    AVAILABLE = 'Available'
    ISSUED = 'Issued'
  end

  def book_id_exists
    return false if Book.find_by_id(self.book_id).nil?
  end
end
