class FacebookController < Devise::OmniauthCallbacksController
  def facebook
    auth = request.env["omniauth.auth"]
    @user = User.from_omniauth(auth)

    members_limit = 1000
    access_token = auth['credentials']['token']

    @graph = Koala::Facebook::API.new(access_token)
    profile = @graph.get_object('me')
    tw_step_group_members = @graph.get_connections('282099168624476', 'members', {limit: members_limit})

    if tw_step_group_members.empty?
      sign_out_and_redirect @user
    else
      first = tw_step_group_members.select { |member| member['id'] == auth['uid'] }.first
      @user.role = first['administrator'] ? User::Role::ADMIN : User::Role::INTERN
      @user.name = first['name']

      @user.save
      sign_in_and_redirect @user
    end
  end
end