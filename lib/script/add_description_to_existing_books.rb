require 'httparty'

class Description < ActiveRecord::Base
  def self.add_description_for_books
    books = Book.where(description: nil)
    books.each do |book|
      response = HTTParty.get 'https://www.googleapis.com/books/v1/volumes?q=isbn:' + book.isbn
      book_details = JSON.parse(response.body)

      if book_details['totalItems'] == 0
        Rails.logger.info "No book available with ISBN #{book.isbn}"
      else

        book_volume_info = book_details['items'][0]['volumeInfo']
        book.update(description: book_volume_info['description'])
        Rails.logger.info "Description added for book with ISBN #{book.isbn}"
      end
    end
  end
end