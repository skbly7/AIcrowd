require 'rails_helper'

describe EmailPreferencesController, type: :controller do
  render_views

  let(:participant)            { create(:participant, :with_email_preferences_token, agreed_to_marketing: false) }
  let(:email_preference)       { participant.email_preferences.first }
  let(:email_preference_token) { participant.email_preferences_tokens.first.email_preferences_token }

  describe "GET #edit" do
    it "assigns the requested email_preference as @email_preference" do
      get :edit, params: { participant_id: participant.id, preferences_token: email_preference_token }

      expect(assigns(:email_preference)).to eq(email_preference)
    end
  end

  describe "PUT #update" do
    it "updates participant agreed_to_marketing field" do
      expect(participant.reload.agreed_to_marketing).to eq(false)

      put :update, params: { participant: { agreed_to_marketing: true }, participant_id: participant.id, preferences_token: email_preference_token }

      expect(participant.reload.agreed_to_marketing).to eq(true)
    end

    it "assigns the requested email_preference as @email_preference" do
      put :update, params: { participant: { agreed_to_marketing: true }, participant_id: participant.id, preferences_token: email_preference_token }

      expect(assigns(:email_preference)).to eq(email_preference)
    end

    it "redirects to the email_preferences_controller" do
      put :update, params: { participant: { agreed_to_marketing: true }, participant_id: participant.id, preferences_token: email_preference_token }

      expect(response).to redirect_to(participant_notifications_path(participant))
    end
  end
end
