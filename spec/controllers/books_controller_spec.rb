require 'spec_helper'

def set_current_user role
  user = double('user')
  user.stub(:role).and_return(role)
  allow(controller).to receive(:current_user) { user }
end

describe BooksController do
  before {
    allow_any_instance_of(ApplicationController).to receive(:authenticate_user!)
  }

  context '#index' do
    it 'should respond with success' do
      expect(Book).not_to receive(:search)
      get :index
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it 'should return book with matching substring' do
      expect(Book).to receive(:sorted_books_search).with('dark')

      params = {:search => 'dark'}
      get :index, params

      expect(response).to be_success
      expect(response).to have_http_status(200)

    end
  end

  context '#list' do
    it 'should respond with success' do
      expect(Book).to receive(:sort_books)

      get :list
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end
  end

  context '#create' do

    context 'validations' do
      it 'should validate presence of title' do
        set_current_user 'Admin'
        params = {isbn: '1234', author: 'R.K.', no_of_copies: '1'}

        post :create, params

        expect(response).to redirect_to(books_manage_path)
        expect(response).to have_http_status(302)
        expect(flash[:error]).to be_present
        expect(flash[:error]).to eq 'something went wrong'
      end

      it 'should validate presence of author' do
        set_current_user 'Admin'
        params = {isbn: '1234', title:'swami and friends', no_of_copies: '1'}

        post :create, params

        expect(response).to redirect_to(books_manage_path)
        expect(response).to have_http_status(302)
        expect(flash[:error]).to be_present
        expect(flash[:error]).to eq 'something went wrong'
      end
    end

    context 'when book is not present in library' do
      it 'should add a book and a book_copy to library' do
        set_current_user 'Admin'
        params = {id: 1, title: 'Java', isbn: '1234', author: 'R.K.', no_of_copies: '1'}

        post :create, params

        expect(response).to redirect_to(books_show_path('1'))
        expect(response).to have_http_status(302)
        expect(flash[:success]).to be_present
        expect(flash[:success]).to eq "Books added successfully to library with ID's 1-1."
      end
    end

    context 'when book is already present in library' do
      it 'should add a book copy' do
        set_current_user 'Admin'
        book = {title: 'Java', isbn: '1235', author: 'R.K.', external_link: ''}
        Book.create(book)
        expect_any_instance_of(Book).not_to receive(:save)
        expect_any_instance_of(BookCopy).to receive(:save).and_return(true)
        book[:no_of_copies] = 1
        book[:tags] = ''
        post :create, book

        expect(response).to redirect_to(books_show_path('1'))
        expect(response).to have_http_status(302)
        expect(flash[:success]).to be_present
      end
    end

    context 'when isbn is not provided' do
      context 'and it is first book to be added' do
        # when isbn is not present we add book_id as isbn, the book gets id when book is saved
        # we handle isbn by taking last book_id+1, so while adding first book to book_id must be 1

        it 'should add book isbn as 1' do
          set_current_user 'Admin'
          params = {title: 'Java', author: 'R.K.', no_of_copies: '1'}

          post :create, params

          book = Book.find(1)
          expect(book.isbn).to eq book.id.to_s
          expect(response).to have_http_status(302)
          expect(flash[:success]).to be_present
        end
      end

      context 'when it is not first book to be added' do

        before do
          set_current_user 'Admin'
          Book.create({title: 'Java', isbn: '1235', author: 'R.K.', external_link: ''})
        end

        it 'should add book id as isbn' do
          params = {title: 'Java', author: 'R.K.', no_of_copies: '1'}
          expected_book_id = Book.last.id + 1

          post :create, params

          book = Book.find(expected_book_id)
          expect(book.isbn).to eq book.id.to_s
          expect(response).to have_http_status(302)
          expect(flash[:success]).to be_present
        end
      end
    end

    it 'should give error when fails to create book copy' do
      set_current_user 'Admin'
      params = {title: 'Java', isbn: '1235', id: '1', author: 'R.K.', no_of_copies: 1}
      expect_any_instance_of(BookCopy).to receive(:save).and_raise(Book::CopyCreationFailedError)
      post :create, params

      expect(response).to redirect_to(books_show_path('1'))
      expect(response).to have_http_status(302)
      expect(flash[:error]).to be_present
    end

    it 'should add a book and 3 book copies to library' do
      set_current_user 'Admin'
      book = {title: 'Java', isbn: '1234', author: 'R.K.', no_of_copies: '3', id: '1', external_link: '', tags: ''}

      post :create, book

      expect(response).to redirect_to(books_show_path('1'))
      expect(response).to have_http_status(302)
      expect(flash[:success]).to be_present
      expect(flash[:success]).to eq "Books added successfully to library with ID's 1-1, 1-2, and 1-3."
    end

    it 'should add tags on book' do
      set_current_user 'Admin'
      tags_string = 'java programming'
      book = {title: 'Java', isbn: '1234', author: 'R.K.', no_of_copies: '1', id: '1', external_link: '', tags: tags_string}

      expect_any_instance_of(Book).to receive(:add_tags).with(tags_string)

      post :create, book

      expect(response).to redirect_to(books_show_path('1'))
      expect(response).to have_http_status(302)
    end

  end

  context '#borrow' do
    it 'should display message for borrowing book and redirect to my books page' do
      user = FactoryGirl.create(:user)
      book = FactoryGirl.create(:book)
      book_copy = FactoryGirl.create(:book_copy, isbn: book.isbn, book_id: book.id, copy_id: "#{book}-1")

      expect_any_instance_of(BooksController).to receive(:current_user).and_return(user)
      freezed_time = Time.now
      Timecop.freeze(freezed_time)

      post :borrow, {:id => book.id}

      expect(flash[:success]).to eq "The book with ID '#{book_copy.copy_id}' has been issued to you and expected return date is '#{(freezed_time + 7.days).strftime("%v")}'"
      expect(response).to have_http_status(302)
      expect(response).to redirect_to(users_books_path)
    end

    it 'should display message for unavailability of book and redirect to my books page' do
      user = FactoryGirl.create(:user)
      book = FactoryGirl.create(:book)

      expect_any_instance_of(BooksController).to receive(:current_user).and_return(user)
      post :borrow, {:id => book.id}

      expect(flash[:error]).to eq "Sorry. #{book.title} is not available"
      expect(response).to have_http_status(302)
      expect(response).to redirect_to(:users_books)
    end
  end

  context '#details' do
    before do
      request.env['HTTP_ACCEPT'] = 'application/json'
    end
    context 'when book is present' do

      it 'should give book details of given isbn' do
        book = FactoryGirl.create(:book, title: 'Java', isbn: '1234', author: 'R.K.', external_link: '')
        params = {:isbn => book[:isbn]}
        get :details, params
        actual_book = JSON.parse(response.body)
        expect(actual_book['isbn']).to eq(book.isbn)
        expect(actual_book['title']).to eq(book.title)
        expect(actual_book['author']).to eq(book.author)
        expect(actual_book['external_link']).to eq(book.external_link)
      end
    end
    context 'when book is not present' do
      book = {title: 'Java', isbn: '1234', author: 'R.K.', no_of_copies: '1', external_link: ''}

      it 'should give empty response' do
        get :details, book
        expect(response.body).to eq('null')
      end
    end
  end

  context '#update' do

    context 'validations' do
      it 'should validate presence of title' do
        params = {isbn: '1234', author: 'R.K.', no_of_copies: '1'}

        post :create, params

        expect(response).to redirect_to(books_manage_path)
        expect(response).to have_http_status(302)
        expect(flash[:error]).to be_present
        expect(flash[:error]).to eq 'something went wrong'
      end

      it 'should validate presence of author' do
        params = {isbn: '1234', title:'swami and friends', no_of_copies: '1'}

        post :create, params

        expect(response).to redirect_to(books_manage_path)
        expect(response).to have_http_status(302)
        expect(flash[:error]).to be_present
        expect(flash[:error]).to eq 'something went wrong'
      end
    end

    context 'should respond with success' do

      before :each do
        set_current_user 'Admin'
        @book = Book.create({title: 'Java', isbn: '1235', author: 'R.K.', external_link: ''})
      end

      it 'should update the book' do
        params = {id: '1',
                  title: 'changed title',
                  isbn: '1234',
                  author: 'changed author',
                  page_count: '1',
                  publisher: 'changed publications',
                  external_link: 'http://some-book-link.com',
                  tags: 'one two three'
        }

        expect(Book).to receive(:find).with(params[:id]).and_return @book
        expect(@book).to receive(:update).with(isbn: params[:isbn] ,title: params[:title], author: params[:author], page_count: params[:page_count],
                                              publisher: params[:publisher], external_link: params[:external_link], return_days: params[:return_days], description: params[:description])
        expect(@book).to receive(:add_tags).with(params[:tags])

        post :update, params

        expect(response).to redirect_to(books_show_path(params[:id]))
        expect(response).to have_http_status(302)
      end

      it 'should update the book with http in the external link' do
        params = {id: '1',
                  title: 'changed title',
                  isbn: '1234',
                  author: 'changed author',
                  page_count: '1',
                  publisher: 'changed publications',
                  external_link: 'www.some-book-link.com',
                  tags: 'one two three'
        }

        expect(Book).to receive(:find).with(params[:id]).and_return @book
        expect(@book).to receive(:update).with(isbn: params[:isbn] ,title: params[:title], author: params[:author], page_count: params[:page_count],
                                              publisher: params[:publisher], external_link: "http://#{params[:external_link]}", return_days: params[:return_days], description: params[:description])

        post :update, params
      end

      it 'should update the book\'s external link as nil if not given' do
        params = {id: '1',
                  title: 'changed title',
                  isbn: '1234',
                  author: 'changed author',
                  page_count: '1',
                  publisher: 'changed publications',
                  external_link: '',
                  tags: 'one two three'
        }

        expect(Book).to receive(:find).with(params[:id]).and_return @book
        expect(@book).to receive(:update).with(isbn: params[:isbn] ,title: params[:title], author: params[:author], page_count: params[:page_count],
                                              publisher: params[:publisher], external_link: nil, return_days: params[:return_days], description: params[:description])

        post :update, params
      end
    end
  end

  context '#update_tags' do
    it 'should update the book tags' do
      book = Book.create({title: 'Java', isbn: '1235', author: 'R.K.', external_link: ''})
      params = {id: '1', tags: 'one two three'}

      expect(Book).to receive(:find).with(params[:id]).and_return book
      expect(book).to receive(:update_tags).with(params[:tags])

      post :update_tags, params

      expect(response).to redirect_to(books_show_path(params[:id]))
      expect(response).to have_http_status(302)
    end
  end
end
