class Participants::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def github
    # You need to implement the method below in your model (e.g. app/models/user.rb)
    @user = Participant.from_omniauth(request.env["omniauth.auth"])
    if @user.persisted?
      sign_in_and_redirect @user
      set_flash_message(:notice, :success, kind: "Github") if is_navigational_format?
    else
      puts "NEW USER"
      session["devise.github_data"] = request.env["omniauth.auth"]
      redirect_to new_participant_registration_url
      ### NATE: had to use this route locally as the base url
      ### was getting set to localhost and I'm not sure why.
      # redirect_to 'http://aicrowd.com:3001/participants/sign_up'
    end
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
      puts "NEW USER"
      Rails.logger.info request.env["omniauth.auth"]
      session["devise.crowdai_data"] = request.env["omniauth.auth"]
      redirect_to new_participant_registration_url
      ### NATE: had to use this route locally as the base url
      ### was getting set to localhost and I'm not sure why.
      # redirect_to 'http://aicrowd.com:3001/participants/sign_up'
    end
  end

  def failure
    redirect_to root_path
  end
end