# frozen_string_literal: true

RSpec.configure do
  def asks_to_sign_in
    expect(response).to redirect_to new_participant_session_path
  end

  def denies_access
    expect(response).to have_http_status(:found)
    expect(response).to redirect_to root_path
    expect(flash[:error]).to match(/You are not authorised to access this page./)
  end
end
