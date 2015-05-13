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
    book_volume_info = book_details['items'][0]['volumeInfo']
    title = book_volume_info['title']
    authors = book_volume_info['authors']
    @book = Book.new({isbn:isbn,title:title,author:authors[0]})
  end
end
