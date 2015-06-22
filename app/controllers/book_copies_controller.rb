class BookCopiesController < ApplicationController
  before_action :authenticate_admin, only: [:disable, :logs]
  def logs
    @book_copy = BookCopy.where(copy_id: params[:id]).first
    @book = @book_copy.book
    @records = Record.includes(:user).all.where(book_copy_id: @book_copy.id)
    @book_copies = @book.book_copies

    current_book_copy = {}
    current_book_copy['status'] = @book_copy.status
    current_book_copy['logs'] = @records

    respond_to do |format|
      format.json { render :json => current_book_copy, :status => :ok, :include => :user}
      format.html { render nothing: true }
    end
  end

  def disable
    book_copy_id = params[:id]
    @book_copy = BookCopy.where(copy_id: book_copy_id ).first
    book = @book_copy.book
    @book_copy.disable
    flash = {message:"Successfully disabled copy #{book_copy_id}"}
    respond_to do |format|
      format.json { render :json => flash, :status => :ok, :include => :user}
      format.html { render nothing: true }
    end
  end
end