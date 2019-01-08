class Participants::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def github
    # You need to implement the method below in your model (e.g. app/models/user.rb)
    @user = Participant.from_omniauth(request.env["omniauth.auth"])

    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication #this will throw if @user is not activated
      set_flash_message(:notice, :success, kind: "Github") if is_navigational_format?
    else
      # session["devise.facebook_data"] = request.env["omniauth.auth"]
      # redirect_to new_user_registration_url
      puts "FAILED LOGIN VIA GITHUB"
    end
  end

  def failure
    redirect_to root_path
  end
end