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

  context '#create' do

    context 'when book is not present in library' do
      it 'should add a book and a book_copy to library' do
        book = {title: 'Java', isbn: '1234', author: 'R.K.'}
        expect_any_instance_of(Book).to receive(:save).and_return(true)
        expect_any_instance_of(BookCopy).to receive(:save).and_return(true)
        post :create, book

        expect(response).to redirect_to(books_manage_path)
        expect(response).to have_http_status(302)
        expect(flash[:success]).to be_present
      end
    end

    context 'when book is already present in library' do
      it 'should add a book copy' do
        book = {title: 'Java', isbn: '1235', author: 'R.K.'}
        Book.create(book)
        expect_any_instance_of(Book).not_to receive(:save)
        expect_any_instance_of(BookCopy).to receive(:save).and_return(true)
        post :create, book

        expect(response).to redirect_to(books_manage_path)
        expect(response).to have_http_status(302)
        expect(flash[:success]).to be_present
      end
    end

    it 'should give error when fails to save book' do
      book = {title: 'Java', isbn: '1235', author: 'R.K.'}
      expect_any_instance_of(Book).to receive(:save).and_return(false)
      post :create, book

      expect(response).to redirect_to(books_manage_path)
      expect(response).to have_http_status(302)
      expect(flash[:error]).to be_present
    end

    it 'should give error when fails to save book copy' do
      book = {title: 'Java', isbn: '1235', author: 'R.K.'}
      expect_any_instance_of(Book).to receive(:save).and_return(true)
      expect_any_instance_of(BookCopy).to receive(:save).and_return(false)
      post :create, book

      expect(response).to redirect_to(books_manage_path)
      expect(response).to have_http_status(302)
      expect(flash[:error]).to be_present
    end
  end
end
