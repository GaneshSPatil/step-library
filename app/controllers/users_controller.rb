class UsersController < ApplicationController
  before_action :authenticate_admin, only: [:index, :show]
  before_action :foo, only: [:index, :show]

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
    @issued_books_records = @user.issued_books_records
  end

  def disable
    user = User.find params[:id]
    user.disable user.id
    redirect_to :users
    flash[:success] = "#{user.name} #{$config['en']['disabled']}"
  end

  private
  def foo
    @current_tab = 'users'
  end
end