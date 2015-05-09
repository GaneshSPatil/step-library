require 'spec_helper'

describe BooksController do

  context "GET #index" do
    it "responds successfully with an HTTP 200 status code" do
      get :index
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it "should search a book" do
      get :index
      # require 'pry'
      # binding.pry
      expect(response).to be_success
    end
  end

end
