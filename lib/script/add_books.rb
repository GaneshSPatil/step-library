require 'csv'
require 'httparty'

class Migration < ActiveRecord::Base

  def self.migrate_books file_name
    @file_name = file_name
    csv_text = File.read(@file_name)
    csv = CSV.parse(csv_text, :headers => false)


    @books_added = []
    @books_failed = []
    csv.each do |row|
      begin
      self.migrate_book row
      sleep(2)

      rescue Exception => ex
        Rails.logger.info ("Exception for book with ISBN #{row[0]}")
        Rails.logger.info (ex)
        @books_failed.push row
      end
    end

    self.write_to_file
  end

  def self.migrate_book row
    isbn = row[0]
    isbn = isbn.squish unless isbn.nil?
    no_of_copies = row[2].to_i
    if isbn.nil?
      @books_failed.push row
      return
    end
    response = HTTParty.get 'https://www.googleapis.com/books/v1/volumes?q=isbn:' + isbn
    book_details = JSON.parse(response.body)

    if book_details['totalItems'] == 0
      @books_failed.push row
      Rails.logger.info "No such Book available with ISBN #{isbn}"
    else
      book_volume_info = book_details['items'][0]['volumeInfo']
      title = book_volume_info['title']
      authors = book_volume_info['authors']  || []
      image_link = book_volume_info['imageLinks']['thumbnail'] if book_volume_info['imageLinks']

      params = {isbn: isbn, title: title, author: authors[0], image_link: image_link}

      @book = Book.where(isbn: params[:isbn]).first
      @book =  Book.create(params) unless @book

      book_copy_ids = @book.create_copies no_of_copies

      begin
        book_copies = @book.create_copies no_of_copies
        book_copy_ids = book_copies.collect(&:copy_id)
        row.push book_copy_ids
        @books_added.push row
        Rails.logger.info "Books added successfully to library with ID's #{book_copy_ids.to_sentence}."
      rescue Book::CopyCreationFailedError => ex
        Rails.logger.info "Something went wrong"
      end
    end
  end

  def self.write_to_file
    CSV.open("books_failed.csv", "w+") do |csv|
      @books_failed.each do |book|
        csv << book
      end
    end

    CSV.open("books_added.csv", "w+") do |csv|
      @books_added.each do |book|
        csv << book
      end
    end
  end
end
