require 'rails_helper'

describe ParticipantChallengesController, type: :controller do
  render_views

  let!(:challenge)              { create(:challenge, :running) }
  let!(:participant)            { create(:participant) }
  let!(:participant_challenges) { create_list(:challenge_participant, 3, challenge: challenge, participant: participant) }
  let!(:admin)                  { create(:participant, :admin) }

  let!(:submission) do
    create(
      :submission,
      participant:        participant,
      challenge:          challenge,
      challenge_round_id: challenge.challenge_rounds.first.id
    )
  end

  before { sign_in(admin) }

  describe 'GET #index challenge_running' do
    before { get :index, params: { challenge_id: challenge.id } }

    it { expect(assigns(:participant_challenges)).to eq participant_challenges }
    it { expect(response).to render_template :index }
  end
end
