class UsersController < ApplicationController
  before_action :authenticate_admin, only: [:index, :show]

  def index
    @current_tab = 'users'
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

  def disable
    user = User.find params[:id]
    user.disable user.id
    redirect_to :users
    flash[:success] = "#{user.name} #{$config['en']['disabled']}"
  end
end