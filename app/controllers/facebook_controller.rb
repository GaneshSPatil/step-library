class FacebookController < Devise::OmniauthCallbacksController
  def facebook
    auth = request.env["omniauth.auth"]
    @user = User.from_omniauth(auth)

    members_limit = 100
    access_token = auth['credentials']['token']

    @graph = Koala::Facebook::API.new(access_token)
    profile = @graph.get_object('me')
    tw_step_group_members = @graph.get_connections('282099168624476', 'members', {limit: members_limit})

    if tw_step_group_members.empty?
      sign_out_and_redirect @user
    else
      @user.role = tw_step_group_members.select { |member| member['id'] == auth['uid'] }.first['administrator'] ? User::Role::ADMIN : User::Role::INTERN
      sign_in_and_redirect @user
    end
  end
end