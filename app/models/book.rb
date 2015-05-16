class Book < ActiveRecord::Base
  has_many :book_copies
  validates :isbn, presence: true
  validates_uniqueness_of :isbn

  def self.search(search_string)
    Book.select { |book| book.title.downcase.include?(search_string.downcase) }
  end

  def self.order_by(field_name)
    Book.order(field_name)
  end

  def copy_available?
    return book_copies.where(status: BookCopy::Status::AVAILABLE).empty? ? false : true
  end

end
