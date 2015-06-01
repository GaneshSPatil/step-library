class FacebookController < Devise::OmniauthCallbacksController
  def facebook
    auth = request.env["omniauth.auth"]
    members = get_group_members(auth)
    authorise_user(auth, members)
  end

  def authorise_user(auth, members)

    if members.empty?
      sign_out_and_redirect ['Oops! You are not a part of STEP', 'Please check if you are logged in on facebook as a valid STEP user']

    elsif User.is_disabled(auth)
      sign_out_and_redirect ['Oops! You do not have access. Contact STEP Administrator']
    else
      sign_in_and_redirect User.from_omniauth(auth, members)
    end
  end

  def sign_out_and_redirect reason
    flash[:sign_in_error] = reason
    redirect_to user_session_path
  end

  def get_group_members(auth)
    members_limit = 1000
    access_token = auth['credentials']['token']
    @graph = Koala::Facebook::API.new(access_token)
    @graph.get_connections(Rails.application.config.group_id, 'members', {limit: members_limit})
  end
end