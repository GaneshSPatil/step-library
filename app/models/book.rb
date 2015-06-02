class Book < ActiveRecord::Base
  has_many :book_copies
  has_many :book_tags

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

  def self.sorted_books_search(search_string)
    books = self.search(search_string)
    self.sort_books(books)
  end

  def number_of_copies
    book_copies.size
  end

  def copy_available?
    book_copies.where(status: BookCopy::Status::AVAILABLE).empty? ? false : true
  end

  def create_copies(no_of_copies)
    created_book_copies = []
    for copy_number in 1..no_of_copies
      copy_id = number_of_copies + copy_number
      book_copy_params = { isbn: isbn, book_id: id, copy_id: copy_id }
      book_copy        = BookCopy.new(book_copy_params)
      created_book_copies.push(book_copy)
    end
    created_book_copies
  end

  def add_tags(tags_string)
    tags = Tag.create_tags(tags_string.split(' '))
    BookTag.add_tags(tags, self)
  end
end
