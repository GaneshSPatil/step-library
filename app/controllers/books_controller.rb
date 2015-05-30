class BooksController < ApplicationController
  before_action :set_book, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_admin, only: [:manage]

  # GET /books
  # GET /books.json
  def index
    @current_tab="home"
    if params[:search]
      @search_parameter = params[:search].squish
      resulted_books = Book.search(@search_parameter)
      @books = Book.sort_books(resulted_books)
      @is_search = true
    else
      @books = []
    end
  end

  # GET /books/1
  # GET /books/1.json
  def show
    @user = User.find current_user.id
    if @user.role == User::Role::ADMIN
      @book_copies = BookCopy.includes(:book).where(book_id: params[:id])
    end
    if @user.has_book?(@book)
      @borrow_button_state = 'hidden'
    else
      @borrow_button_state = @book.copy_available? ? 'show' : 'disabled'
    end
  end

  # GET /books/manage
  def manage
    @current_tab = 'manage_books'
    @book = Book.new
  end

  def list
    all_books = Book.all
    @books = Book.sort_books(all_books)
  end

  def borrow
    @book     = Book.find params[:id]
    book_copy = BookCopy.where(book_id: params[:id], status: BookCopy::Status::AVAILABLE).first
    if book_copy
      current_user_id = current_user.id
      book_copy.issue current_user_id
      Rails.logger.info("The book with ID '#{@book.id}-#{book_copy.copy_id}' has been issued to #{current_user_id} user")
      flash[:success] = "The book with ID '#{@book.id}-#{book_copy.copy_id}' has been issued to you."
    else
      flash[:error] = "Sorry. #{@book.title} is not available"
    end
    redirect_to :books_show, { :id => params[:id] }
  end

  def return
    book_copy_id = params[:id]
    current_user.return_book book_copy_id
    flash[:success] = 'Book returned to library..!'
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
    isbn          = params[:isbn]
    books_by_isbn = Book.where({ isbn: isbn })
    if books_by_isbn.empty?
      @book = new_book(params)
      unless @book.save
        return render_create_error(@book)
      end
    else
      @book = books_by_isbn.first
    end

    book_copies = @book.create_copies(params[:no_of_copies].to_i)
    book_copy_ids = []

    if book_copies.all?(&:valid?)
      book_copies.each(&:save)
      Rails.logger.info("#{params[:no_of_copies]} copies of book with isbn:- #{@book.isbn} title:- #{@book.title} inserted successfully.")
    else
      return render_create_error(@book)
    end

    book_copies.map do |book_copy|
      book_copy_ids.push "'#{@book.id}-#{book_copy.copy_id}'"
    end

    flash[:success] = "Books added successfully to library with ID's #{book_copy_ids.to_sentence}."
    redirect_to books_manage_path
  end

  # PATCH/PUT /books/1
  # PATCH/PUT /books/1.json
  def update
    respond_to do |format|
      if @book.update(book_params)
        format.html { redirect_to @book, notice: 'Book was successfully updated.' }
        format.json { render :show, status: :ok, location: @book }
      else
        format.html { render :edit }
        format.json { render json: @book.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /books/1
  # DELETE /books/1.json
  def destroy
    @book.destroy
    respond_to do |format|
      format.html { redirect_to books_url, notice: 'Book was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
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
    flash[:error] = "something went wrong"
    return redirect_to books_manage_path
  end

  def new_book(params)
    Book.new({ isbn: params[:isbn], title: params[:title], author: params[:author], image_link: params[:image_link] })
  end
end
