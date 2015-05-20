class FacebookController < Devise::OmniauthCallbacksController
  def facebook
    auth = request.env["omniauth.auth"]
    members = get_group_members(auth)
    authorise_user(auth, members)
  end

  def authorise_user(auth, members)

    if members.empty? || User.is_disabled(auth)
      sign_out_and_redirect
    else
      sign_in_and_redirect User.from_omniauth(auth, members)
    end
  end

  def sign_out_and_redirect
    flash[:sign_in_error] = ['Oops! You are not a part of STEP', 'Please check if you are logged in on facebook as a valid STEP user']
    redirect_to user_session_path
  end

  def get_group_members(auth)
    members_limit = 1000
    access_token = auth['credentials']['token']
    @graph = Koala::Facebook::API.new(access_token)
    @graph.get_connections(Rails.application.config.group_id, 'members', {limit: members_limit})
  end
end