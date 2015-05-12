require 'spec_helper'

describe BooksController do
  before {
    allow_any_instance_of(ApplicationController).to receive(:authenticate_user!)
  }

  context "#index" do
    it "should respond with success" do
      expect(Book).not_to receive(:search)
      get :index
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it "should return book with matching substring" do
      expect(Book).to receive(:search).with('dark')

      params = {:search => 'dark'}
      get :index, params

      expect(response).to be_success
      expect(response).to have_http_status(200)

    end
  end

  context "#list" do
    it "should respond with success" do
      expect(Book).to receive(:order_by).with('title')

      get :list
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

  end
end
