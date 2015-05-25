class Book < ActiveRecord::Base
  has_many :book_copies
  validates :isbn, presence: true
  validates_uniqueness_of :isbn

  def self.search(search_string)
    Book.where('title LIKE ?', '%' + search_string + '%').all
  end

  def self.sort_books(all_books)
    available_books = all_books.select { |book| book.copy_available? }.sort_by{ |b| b.title }
    unavailable_books = all_books.select { |book| !book.copy_available? }.sort_by{ |b| b.title }
    available_books + unavailable_books
  end

  def copy_available?
    book_copies.where(status: BookCopy::Status::AVAILABLE).empty? ? false : true
  end

end
