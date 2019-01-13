class Participants::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def github
    oauth2_generic
  end

  def oauth2_generic
    @user = Participant.from_omniauth(request.env["omniauth.auth"])
    if @user.persisted?
      if(!@user.confirmed?)
        @user.confirm
        token = @user.send(:set_reset_password_token)
        redirect_to edit_password_path(@user, reset_password_token: token)
      else
        set_flash_message(:notice, :success, kind: "Crowdai") if is_navigational_format?
        sign_in_and_redirect @user
      end
    else
      session["devise.omniauth_data"] = request.env["omniauth.auth"]
      redirect_to new_participant_registration_path
    end
  end

  def failure
    redirect_to root_path
  end
end