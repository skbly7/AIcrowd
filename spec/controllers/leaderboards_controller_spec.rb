require 'rails_helper'

describe LeaderboardsController, type: :controller do
  render_views

  context 'current round' do
    let(:challenge)   { create(:challenge, :running) }
    let(:participant) { create(:participant) }
    let(:user)        { create(:participant) }

    before { sign_in user }

    describe 'GET #index' do
      let!(:submissions) { create_list(:submission, 3, challenge: challenge, participant: participant, grading_status_cd: 'graded') }

      before { get :index, params: { challenge_id: challenge.id } }

      it { expect(response).to render_template :index }
    end
  end
end
