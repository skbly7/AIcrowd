require 'rails_helper'

describe FollowsController, type: :controller do
  render_views

  let!(:challenge)   { create(:challenge) }
  let!(:participant) { create(:participant) }

  context 'participant' do
    before do
      sign_in participant
    end

    describe "Follow a Challenge" do
      def follow
        post :create, format: :js, params: { challenge_id: challenge.id }
        challenge.reload
      end

      it { expect { follow }.to change { Follow.count }.by(1) }
      it { expect { follow }.to change { challenge.follows.count }.by(1) }
      it { expect { follow }.to change { participant.follows.count }.by(1) }
    end

    describe "Unfollow a Challenge" do
      let!(:follow) { create(:follow, followable: challenge, participant: participant) }

      def unfollow
        delete :destroy, format: :js, params: { challenge_id: challenge.id, id: follow.id }
      end

      it { expect { unfollow }.to change { Follow.count }.by(-1) }
      it { expect { unfollow }.to change { challenge.reload.follows.count }.by(-1) }
      it { expect { unfollow }.to change { participant.reload.follows.count }.by(-1) }
    end
  end
end
