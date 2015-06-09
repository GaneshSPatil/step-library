require 'httparty'

  class AddDescriptionPagecountPublisherToBook < ActiveRecord::Base
  def self.add file=nil
    @isbn_failed = []

    if file
      isbn_numbers = JSON.parse(File.read(file))
    else
      isbn_numbers = Book.pluck(:isbn) unless file
    end

    isbn_numbers.each do |isbn|
      sleep(5)
      update_book_for(isbn)
    end

    self.write_to_file
  end

  def self.update_book_for(isbn)
    begin
      response = HTTParty.get 'https://www.googleapis.com/books/v1/volumes?q=isbn:' + isbn
      book_details = JSON.parse(response.body)

      if book_details['totalItems'] == 0
        @isbn_failed.push isbn
        Rails.logger.info "No book available with ISBN #{isbn}"
      else
        book = Book.where(isbn: isbn).first
        book_volume_info = book_details['items'][0]['volumeInfo']
        book.update(description: book_volume_info['description'], publisher: book_volume_info['publisher'], page_count: book_volume_info['pageCount'])
        Rails.logger.info "Description, Publisher, Page count added for book with ISBN #{isbn}"
      end
    rescue Exception => ex
      @isbn_failed.push isbn
      Rails.logger.info "Something went wrong while updating book with ISBN #{isbn}"
    end
  end

  def self.write_to_file
    File.open('books_failed_to_add_description_pages_publication.txt', 'w') {|f| f.write(@isbn_failed) }
  end

end