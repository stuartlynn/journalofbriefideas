class AuthenticationsController < ApplicationController
  #
  # We use this only to connect oauth accounts to existing wL accounts, at
  # present.
  #
  def create
    auth = env["omniauth.auth"]
    @user = User.find_for_fig_oauth(auth, current_user)

    binding.pry
    if @user.persisted?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Facebook"
      sign_in_and_redirect @user, :event => :authentication
    else
      session["devise.figshare_data"] = auth
      redirect_to new_user_registration_url
    end

    # ...
    # You should store
    #   auth.credentials.token
    #   auth.credentials.secret
    # for future authentication against the figshare API. auth[:uid] is the
    # user's figshare user id.
    #
    # hint: check env['omniauth.origin'] to redirect the user to wherever they
    # were trying to get to before connecting
  end
end