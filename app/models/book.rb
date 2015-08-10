class Book < ActiveRecord::Base
  has_many :book_copies
  has_many :book_tags
  has_many :tags, through: :book_tags, source: :tag

  validates :isbn, presence: true
  validates_uniqueness_of :isbn

  class CopyCreationFailedError < StandardError;
  end

  def self.search(search_string)
    search_string = search_string.downcase
    Book.all.select{|b|
      (b.title && b.title.downcase.include?(search_string)) ||
      (b.author && b.author.downcase.include?(search_string)) ||
      (b.isbn && b.isbn.downcase.include?(search_string)) ||
      (b.publisher && b.publisher.downcase.include?(search_string)) ||
      (!b.tags.blank? && b.tags.any? { |t| t.name.downcase.include?(search_string)})
    }
  end

  def self.sort_books(all_books)
    available_books = all_books.select { |book| book.copy_available? }.sort_by{ |b| b.title }
    unavailable_books = all_books.select { |book| !book.copy_available? }.sort_by{ |b| b.title }
    available_books + unavailable_books
  end

  def self.search_and_sort_by term, search_param
    books = Book.where("#{term} LIKE ?", '%' + search_param + '%').all
    available = books.select { |book| book.copy_available? }.sort_by{ |b| b.title }
    unavailable = books - available
    available + unavailable
  end

  def self.search_and_sort_tag search_param
    tag_ids = Tag.where("name LIKE ?", '%' + search_param + '%').collect(&:id)
    book_tags = BookTag.where(tag_id: tag_ids).collect(&:book_id)
    books = Book.where(id: book_tags)
    available = books.select { |book| book.copy_available? }.sort_by{ |b| b.title }
    unavailable = books - available
    available + unavailable
  end

  def self.sorted_books_search(search_string)
    books = self.search(search_string)
    self.sort_books(books)
  end

  def number_of_copies
    self.book_copies.size
  end

  def copy_available?
    book_copies.where(status: BookCopy::Status::AVAILABLE).empty? ? false : true
  end

  def create_copies(no_of_copies)
    copies_created = []
    old_copies_count = number_of_copies
    for copy_number in 1..no_of_copies
      copy_id = "#{self.id}-#{old_copies_count + copy_number}"

      begin
        book_copy = BookCopy.create(isbn: self.isbn, book_id: self.id, copy_id: copy_id)
        copies_created.push(book_copy)
        Rails.logger.info("Copy #{copy_id} of book with isbn:- #{self.isbn} title:- #{self.title} inserted successfully.")
      rescue Exception => ex
        Rails.logger.info("Copy #{copy_id} of book with isbn:- #{self.isbn} title:- #{self.title} failed to create")
        raise CopyCreationFailedError
      end
    end
    copies_created
  end

  def add_tags(tags)
    tags = Tag.create_tags(tags.split(' '))
    self.tags = tags
  end

  def get_tags
    self.tags
  end

  def update_tags(tags_text)
    self.add_tags(tags_text)
  end

  def update_expected_return_days new_return_days
    return if new_return_days == self.return_days

    self.update(return_days: new_return_days)
    book_copy_ids = book_copies.collect(&:id)
    records = Record.where(book_copy_id: book_copy_ids, return_date: nil)

    records.each do |record|
      record.update(expected_return_date: record.borrow_date + new_return_days.days)
    end
  end
end
