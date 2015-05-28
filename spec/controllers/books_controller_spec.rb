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
      expect(Book).to receive(:sort_books)

      params = {:search => 'dark'}
      get :index, params

      expect(response).to be_success
      expect(response).to have_http_status(200)

    end
  end

  context "#list" do
    it "should respond with success" do
      expect(Book).to receive(:sort_books)

      get :list
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end
  end

  context '#create' do

    context 'when book is not present in library' do
      it 'should add a book and a book_copy to library' do
        book = {title: 'Java', isbn: '1234', author: 'R.K.', no_of_copies: '1'}
        expect_any_instance_of(Book).to receive(:save).and_return(true)
        expect_any_instance_of(BookCopy).to receive(:save).and_return(true)
        post :create, book

        expect(response).to redirect_to(books_manage_path)
        expect(response).to have_http_status(302)
        expect(flash[:success]).to be_present
        expect(flash[:success]).to eq "Books added successfully to library with ID's '#{book[:id]}-#{1}'."
      end
    end

    context 'when book is already present in library' do
      it 'should add a book copy' do
        book = {title: 'Java', isbn: '1235', author: 'R.K.'}
        Book.create(book)
        expect_any_instance_of(Book).not_to receive(:save)
        expect_any_instance_of(BookCopy).to receive(:save).and_return(true)
        book[:no_of_copies] = 1
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
      book = {title: 'Java', isbn: '1235', author: 'R.K.', no_of_copies: 1}
      expect_any_instance_of(Book).to receive(:save).and_return(true)
      expect_any_instance_of(BookCopy).to receive(:valid?).and_return(false)
      post :create, book

      expect(response).to redirect_to(books_manage_path)
      expect(response).to have_http_status(302)
      expect(flash[:error]).to be_present
    end

    it 'should add a book and 3 book copies to library' do
      book = {title: 'Java', isbn: '1234', author: 'R.K.', no_of_copies: '3', id: '1'}

      post :create, book

      expect(response).to redirect_to(books_manage_path)
      expect(response).to have_http_status(302)
      expect(flash[:success]).to be_present
      expect(flash[:success]).to eq "Books added successfully to library with ID's '#{book[:id]}-#{1}', '#{book[:id]}-#{2}', and '#{book[:id]}-#{3}'."
    end

  end

  context "#borrow" do
    it "should display message for borrowing book and redirect to book show page" do
      user = FactoryGirl.create(:user)
      book = FactoryGirl.create(:book)
      book_copy = FactoryGirl.create(:book_copy, isbn: book.isbn, book_id:book.id, copy_id:1)

      expect_any_instance_of(BooksController).to receive(:current_user).and_return(user)

      post :borrow, {:id => book.id}

      expect(flash[:success]).to eq "The book with ID '#{book.id}-1' has been issued to you."
      expect(response).to have_http_status(302)
      expect(response).to redirect_to(books_show_path)
    end

    it "should display message for unavailability of book and redirect to book show page" do
      user = FactoryGirl.create(:user)
      book = FactoryGirl.create(:book)

      post :borrow, {:id => book.id}

      expect(flash[:error]).to eq "Sorry. #{book.title} is not available"
      expect(response).to have_http_status(302)
      expect(response).to redirect_to(books_show_path)
    end
  end
end
