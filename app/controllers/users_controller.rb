class UsersController < ApplicationController
  before_action :authenticate_admin, only: [:index, :show]

  def index
    search_param = params[:search]
    if search_param
      @users = User.search(search_param)
      @is_search = true
    else
      @users = []
    end
  end

  def books
    user = User.find(current_user.id)
    @books = user.books
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
