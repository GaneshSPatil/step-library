class BookCopiesController < ApplicationController
  def logs
    book_copy_id = params[:id]
    @book         = BookCopy.where(id: book_copy_id).first.book
    @book_copies = BookCopy.where(book_id: @book.id)
    @records = Record.includes(:user).all.where("records.book_copy_id == #{book_copy_id}")

    respond_to do |format|
      format.json { render :json => @records, :status => :ok, :include => :user}
      format.html { render nothing: true }
    end
  end
end