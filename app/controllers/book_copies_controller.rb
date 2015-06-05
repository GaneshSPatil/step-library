class BookCopiesController < ApplicationController
  before_action :authenticate_admin
  def logs
    @book_copy = BookCopy.where(copy_id: params[:id]).first
    @book = @book_copy.book
    @records = Record.includes(:user).all.where(book_copy_id: @book_copy.id)

    @book_copies = @book.book_copies

    respond_to do |format|
      format.json { render :json => @records, :status => :ok, :include => :user}
      format.html { render nothing: true }
    end
  end
end