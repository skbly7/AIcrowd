require 'rails_helper'

describe LeaderboardsController, feature: true do
  describe '#index' do
    let!(:challenge)                       { create(:challenge, :completed) }
    let!(:challenge_round)                 { challenge.challenge_rounds.first }
    let!(:participants)                    { create_list(:participant, 3) }
    let!(:leaderboard)                     { create(:base_leaderboard, challenge: challenge, challenge_round: challenge_round, score: 77) }
    let!(:leaderboard_without_participant) { create(:base_leaderboard, challenge: challenge, challenge_round: challenge_round, participant: nil) }
    let!(:team)                            { create(:team, participants: participants) }
    let!(:leaderboard_with_team)           { create(:base_leaderboard, submitter: team, challenge: challenge, challenge_round: challenge_round ) }

    context 'when user is not logged in' do
      it 'renders leaderboards listing' do
        visit challenge_leaderboards_path(challenge)

        expect(page).to have_http_status 200
        expect(page).to have_current_path challenge_leaderboards_path(challenge)
        expect(page).to have_content('77')
      end
    end

    context 'when user is logged in' do
      let(:admin) { create(:participant, :admin) }

      before { log_in admin }

      it 'renders leaderboards listing' do
        visit challenge_leaderboards_path(challenge)

        expect(page).to have_http_status 200
        expect(page).to have_current_path challenge_leaderboards_path(challenge)
        expect(page).to have_content('77')
      end
    end
  end
end
