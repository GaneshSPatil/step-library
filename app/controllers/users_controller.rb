class UsersController < ApplicationController
  before_action :authenticate_admin, only: [:index, :show]
  before_action :foo, only: [:index, :show]

  def index
    @disabled_users = User.disabled ""
    @current_tab = 'users'
    if params[:search]
      search_parameter = params[:search].squish
      @users = User.search(search_parameter)
      @is_search = true
    else
      @users = User.search ""
    end
    respond_to do |format|
      format.json { render json: @users, status: 200}
      format.html
    end
  end

  def books
    @book_copies = current_user.book_copies
  end

  def show
    @user = User.find params[:id]
    @issued_books_records = @user.issued_books_records
    @logs = @user.logs
  end

  def disabled
    search_param = params[:search_disabled] || ""
    @disabled_users = User.disabled search_param
    @users = User.search ""
    respond_to do |format|
      format.json { render json: @disabled_users, status: 200}
    end
  end

  def disable
    user = User.find params[:id]
    user.disable
    redirect_to :users
    flash[:success] = "#{user.name} #{$config['en']['disabled']}"
  end

  def manual
    file_name = (current_user.role == "Admin") ? "admin-manual.pdf" : "intern-manual.pdf"
    send_file "#{Rails.root}/app/assets/#{file_name}", filename: "#{file_name}", disposition:'inline',type: 'application/pdf',x_sendfile: true
  end

  private
  def foo
    @current_tab = 'users'
  end
end
