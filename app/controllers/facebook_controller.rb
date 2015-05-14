class FacebookController < Devise::OmniauthCallbacksController
  def facebook
    auth = request.env["omniauth.auth"]
    @user = User.from_omniauth(auth)

    members_limit = 1000
    access_token = auth['credentials']['token']

    @graph = Koala::Facebook::API.new(access_token)
    profile = @graph.get_object('me')
    tw_step_group_members = @graph.get_connections(Rails.application.config.group_id, 'members', {limit: members_limit})
    if tw_step_group_members.empty?
      @user.destroy
      sign_out @user
      flash[:sign_in_error] = 'Oops! You are not a part of STEP';
      redirect_to '/user/sign_in'
    else
      first = tw_step_group_members.select { |member| member['id'] == auth['uid'] }.first
      @user.role = first['administrator'] ? User::Role::ADMIN : User::Role::INTERN
      @user.name = first['name']

      @user.save
      sign_in_and_redirect @user
    end
  end
end