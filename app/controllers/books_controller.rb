class BooksController < ApplicationController
  before_action :set_book, only: [:show, :edit, :update, :update_tags]
  before_action :validate_fields, only: [:update, :create]
  before_action :authenticate_admin, only: [:manage, :create, :update]

  # GET /books
  # GET /books.json
  def index
    @current_tab='home'
    if params[:search]
      @search_parameter = params[:search].squish
      @books = search_books
      @is_search = true
    else
      @books = []
    end
  end

  # GET /books/1
  # GET /books/1.json
  def show
    @book = Book.find(params[:id])
    @user = User.find current_user.id
    if @user.role == User::Role::ADMIN
      @book_copies = BookCopy.where(book_id: params[:id])
    end
    if @user.has_book?(@book)
      @borrow_button_state = 'hidden'
      @is_book_borrowed = true
      @record = @user.records.select { |r| r.book_copy.book == @book }.first
    else
      @borrow_button_state = @book.copy_available? ? 'show' : 'disabled'
      @is_book_borrowed = false
    end
    @tags = @book.get_tags.map(&:name)
  end

  # GET /books/manage
  def manage
    @current_tab = 'manage_books'
    @book = Book.new
    @records = Record.includes({:book_copy => :book}, :user).where(:return_date => nil)
  end

  def list
    all_books = Book.includes(:tags)
    @books = Book.sort_books(all_books)
  end

  def borrow
    @book = Book.find params[:id]
    @user = User.find current_user.id
    if @user.has_book?(@book)
      @borrow_button_state = 'hidden'
      flash[:error] = "'#{@book.title}' is already borrowed by you."
    else
      book_copy = BookCopy.where(book_id: params[:id], status: BookCopy::Status::AVAILABLE).first
      if book_copy
        current_user_id = @user.id
        book_copy.issue current_user_id
        Rails.logger.info("The book with ID '#{@book.id}-#{book_copy.copy_id}' has been issued to #{current_user_id} user")
        flash[:success] = "The book with ID '#{book_copy.copy_id}' has been issued to you and expected return date is '#{(Time.now + @book.return_days.days).strftime("%v")}'"
      else
        flash[:error] = "Sorry. #{@book.title} is not available"
      end
    end
    redirect_to :users_books
  end

  def return
    book_copy_id = params[:id]
    current_user.return_book book_copy_id
    flash[:success] = 'Book returned to library.'
    redirect_to :users_books
  end

  # GET /books/new
  def new
    @book = Book.new
  end

  # GET /books/1/edit
  def edit
  end

  # POST /books
  # POST /books.json
  def create
    isbn = params[:isbn]
    @book = Book.where({isbn: isbn}).first

    @book = create_book(params) unless @book
    @book.add_tags(params[:tags]) if params[:tags]

    begin
      book_copies = @book.create_copies(params[:no_of_copies].to_i)
      book_copy_ids = book_copies.collect(&:copy_id)
      flash[:success] = "Books added successfully to library with ID's #{book_copy_ids.to_sentence}."
    rescue Book::CopyCreationFailedError => ex
      flash[:error] = 'Something went wrong'
    end
    redirect_to books_show_path(@book.id)
  end

  def details
    isbn = params[:isbn]
    @book = Book.where({isbn: isbn}).first

    respond_to do |format|
      format.json { render :json => @book, :status => :ok }
    end
  end

  # PATCH/PUT /books/1
  # PATCH/PUT /books/1.json
  def update
    @book.update(isbn: params[:isbn], title: params[:title], author: params[:author], page_count: params[:page_count], publisher: params[:publisher], external_link: prepend_http_to(params[:external_link]), description: params[:description])
    @book.update_expected_return_days(params[:return_days].to_i)
    @book.add_tags(params[:tags])
    redirect_to books_show_path, {id: @book.id}
  end

  def update_tags
    @book.update_tags(params[:tags])
    redirect_to books_show_path, {id: @book.id}
  end

  private


  def search_books
    book_with_title=Book.search_and_sort_by('title', @search_parameter)
    book_with_author=Book.search_and_sort_by('author', @search_parameter)
    book_with_publisher=Book.search_and_sort_by('publisher', @search_parameter)
    book_with_isbn=Book.search_and_sort_by('isbn', @search_parameter)
    book_with_tag=Book.search_and_sort_tag(@search_parameter)

    {'title' => book_with_title, 'author' => book_with_author, 'publisher' => book_with_publisher, 'isbn' => book_with_isbn, 'tag' => book_with_tag}
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_book
    @book = Book.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def book_params
    params[:book]
  end

  def render_create_error (book)
    Rails.logger.error("Book insertion failed for isbn:- #{book.isbn} with errors:-#{book.errors.full_messages}")
    flash[:error] = 'something went wrong'
    redirect_to books_manage_path
  end

  def create_book(params)
    ext_link = params[:external_link]
    isbn = params[:isbn]
    if ext_link.present?
      external_link = prepend_http_to(ext_link)
    end

    unless isbn.present?
      isbn = Book.last.nil? ? 1.to_s : (Book.last.id + 1).to_s
    end

    Book.create({
                  isbn: isbn,
                  title: params[:title],
                  author: params[:author],
                  image_link: params[:image_link],
                  external_link: external_link,
                  page_count: params[:page_count],
                  publisher: params[:publisher],
                  description: params[:description],
                  return_days: params[:return_days]
                })
  end

  def prepend_http_to(ext_link)
    return nil if ext_link == ''
    if ext_link.start_with?('http://') || ext_link.start_with?('https://')
      external_link = ext_link
    else
      external_link = "http://#{ext_link}"
    end
    external_link
  end

  def validate_fields
    if !params[:title].present? || !params[:author].present?
      flash[:error] = 'something went wrong'
      redirect_to books_manage_path
    end
  end
end
