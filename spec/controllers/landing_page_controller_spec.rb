require 'rails_helper'

describe LandingPageController, type: :controller do
  render_views

  let!(:challenge_draft)         { create(:challenge, :draft, challenge: 'challenge_draft') }
  let!(:challenge_running)       { create(:challenge, :running, challenge: 'challenge_running') }
  let!(:challenge_completed)     { create(:challenge, :completed, challenge: 'challenge_completed') }
  let!(:challenge_starting_soon) { create(:challenge, :starting_soon, challenge: 'challenge_starting_soon') }
  let!(:participant)             { create(:participant) }
  let!(:admin)                   { create(:participant, admin: true) }

  context 'participant' do
    before { sign_in participant }

    describe 'GET #index challenge_running' do
      before { get :index }

      it { expect(assigns(:challenges)).to eq [challenge_running, challenge_completed, challenge_starting_soon] }
      it { expect(response).to render_template :index }
    end
  end

  context 'anonymous user' do
    describe 'GET #index challenge_running' do
      before { get :index }

      it { expect(assigns(:challenges)).to eq [challenge_running, challenge_completed, challenge_starting_soon] }
      it { expect(response).to render_template :index }
    end
  end
end
