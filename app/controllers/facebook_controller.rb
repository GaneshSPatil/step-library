class FacebookController < Devise::OmniauthCallbacksController
  def facebook
    auth = request.env["omniauth.auth"]
    members = get_user_details(auth)
    authorise_user(auth, members)
  end

  def authorise_user(auth, members)
    if members.empty?
      sign_out_and_redirect
    else
      sign_in_to_library(auth, members)
    end
  end

  def sign_in_to_library(auth, members)
    first = members.select { |member| member['id'] == auth['uid'] }.first
    @user.role = first['administrator'] ? User::Role::ADMIN : User::Role::INTERN
    @user.name = first['name']
    @user.save
    sign_in_and_redirect @user
  end

  def sign_out_and_redirect
    @user.destroy
    sign_out @user
    flash[:sign_in_error] = 'Oops! You are not a part of STEP';
    redirect_to '/user/sign_in'
  end

  def get_user_details(auth)
    @user = User.from_omniauth(auth)
    members_limit = 1000
    access_token = auth['credentials']['token']
    @graph = Koala::Facebook::API.new(access_token)
    @graph.get_connections(Rails.application.config.group_id, 'members', {limit: members_limit})
  end
end