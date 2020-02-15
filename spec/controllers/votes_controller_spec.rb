require 'rails_helper'

describe VotesController, type: :controller do
  render_views

  let!(:challenge)   { create(:challenge) }
  let!(:participant) { create(:participant) }

  context 'participant' do
    before { sign_in participant }

    describe "POST #create for Challenge" do
      def register_vote
        post :create, format: :js, params: { challenge_id: challenge.id }
        challenge.reload
      end

      it { expect { register_vote }.to change(Vote, :count).by(1) }
      it { expect { register_vote }.to change(challenge, :vote_count).by(1) }
    end
  end
end
