require 'rails_helper'

describe VotesHelper do
  let!(:participant) { create :participant }
  let!(:other_participant) { create :participant }
  let!(:challenge) { create :challenge }

  describe 'challenge vote count' do
    context 'participant has voted' do
      before do
        allow(helper).to receive(:current_participant) { participant }
        challenge.votes.create!(participant_id: participant.id)
      end

      it { expect(challenge.votes.count).to eq(1) }
    end

    context 'participant has not voted' do
      before do
        allow(helper).to receive(:current_participant) { participant }
        challenge.votes.create!(participant_id: other_participant.id)
      end

      it { expect(challenge.votes.count).to eq(1) }
    end
  end
end
