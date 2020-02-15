require 'rails_helper'

# This is to make sure that the legacy `TeamsController` redirects as expected to
# the proper `Challenges::TeamsController` actions where possible
describe TeamsController, type: :controller do
  render_views

  let!(:challenge) { create(:challenge) }

  describe 'GET #show' do
    let!(:participant) { create(:participant) }
    let!(:team)        { create(:team, challenge: challenge, participants: [participant]) }

    before { get :show, params: { name: team.name } }

    context 'standard' do
      it { expect(response).to have_http_status(:moved_permanently) }
      it { expect(response).to redirect_to(challenge_team_url(team.challenge, team)) }
    end

    context 'with aliased team name' do
      let!(:challenge2)   { create(:challenge) }
      let!(:participant2) { create(:participant) }
      let!(:team2)        { create(:team, name: team.name, challenge: challenge2, participants: [participant2]) }

      before { get :show, params: { name: team2.name } }

      it { expect(response).to have_http_status(:moved_permanently) }
      it { expect(response).to redirect_to(challenge_team_url(team.challenge, team)) }
    end


    context 'with dotted names' do
      let!(:participant) { create(:participant, name: 'participant.withdot') }
      let!(:team)        { create(:team, challenge: challenge, participants: [participant], name: 'team.withdot') }

      before { get :show, params: { name: team.name } }

      it { expect(response).to have_http_status(:moved_permanently) }
      it { expect(response).to redirect_to(challenge_team_url(team.challenge, team)) }
    end

    context 'with unknown name' do
      it { expect { get :show, params: { name: FFaker::Name.unique.first_name } }.to raise_error(ActiveRecord::RecordNotFound) }
    end
  end
end
