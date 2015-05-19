class UsersController < ApplicationController
  before_action :authenticate_admin, only: [:index, :show]

  def index
    if params[:search]
      search_parameter = params[:search].squish
      @users = User.search(search_parameter)
      @is_search = true
    else
      @users = []
    end
  end

  def books
    @book_copies = current_user.book_copies
  end

  def show
    @user = User.find params[:id]
    @books = @user.books
  end

  private
  def authenticate_admin
    if current_user.role != 'Admin'
      render 'layouts/404', status: 404
    end
  end

end
