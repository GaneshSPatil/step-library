class BooksController < ApplicationController
  before_action :set_book, only: [:show, :edit, :update, :destroy]

  # GET /books
  # GET /books.json
  def index
    if params[:search]
      @books = Book.search(params[:search].strip.gsub(/\s+/, ' '))
      @is_search = true
    else
      @books = []
    end
  end

  # GET /books/1
  # GET /books/1.json
  def show
  end

  # GET /books/manage
  def manage
  end

  def list
    @books = Book.order_by('title')
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
    books_by_isbn = Book.where({isbn: isbn})
    if books_by_isbn.empty?
      @book = new_book(params)
      unless @book.save
        return render_create_error(@book)
      end
    else
      @book = books_by_isbn.first
    end

    book_copy_params = {isbn: isbn, book_id: @book.id}
    book_copy = BookCopy.new(book_copy_params)
    if book_copy.save
      Rails.logger.info("Book with isbn:- #{@book.isbn} title:- #{@book.title} inserted successfully")
    else
      return render_create_error(@book)
    end

    flash[:success] = 'Book was successfully added.'
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
    Book.new({isbn: params[:isbn], title: params[:title], author: params[:author], image_link: params[:image_link]})
  end
end
