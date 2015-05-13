require 'net/http'
require 'json'
class GoogleApisController < ApplicationController
  def fetch
    isbn = params[:ISBN]
    google_api_url = "https://www.googleapis.com/books/v1/volumes\?q\=isbn:#{isbn}"
    uri = URI.parse(google_api_url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(uri.request_uri)

    response = http.request(request)
    book_details = JSON.parse(response.body)
    if book_details['totalItems'] == 0
      flash[:error] = "No such Book available with ISBN #{isbn}"
      redirect_to books_manage_path
    else
      book_volume_info = book_details['items'][0]['volumeInfo']
      title = book_volume_info['title']
      authors = book_volume_info['authors']
      image_links = book_volume_info['imageLinks']
      params = {isbn: isbn, title: title, author: authors[0]}
      if image_links
        params[:image_link] = image_links['thumbnail']
      end
      @book = Book.new(params)
    end
  end
end
