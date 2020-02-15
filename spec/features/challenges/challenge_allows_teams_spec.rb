require 'rails_helper'

describe 'Challenge Teams' do
  let!(:challenge_no_teams) { create :challenge, :running, teams_allowed: false }
  let!(:challenge_with_max_5_members) { create :challenge, :running, teams_allowed: true }
  let!(:challenge_rules) { create :challenge_rules, challenge: challenge_no_teams }
  let!(:challenge_rules) { create :challenge_rules, challenge: challenge_with_max_5_members }
  let!(:participation_terms) { create :participation_terms }

  let!(:participant) { create :participant }

  let!(:challenge_participant) { create :challenge_participant, challenge: challenge_no_teams, participant: participant }
  let!(:challenge_participant) { create :challenge_participant, challenge: challenge_with_max_5_members, participant: participant }

  describe "Challenge should allow teams" do
    it "Challenge does not allow teams" do
      log_in(participant)
      visit challenge_path(challenge_no_teams)
      expect(page).to have_no_content 'My Team'
      expect(page).to have_no_content 'Create Team'
    end

    it "Challenge does allow teams" do
      log_in(participant)
      visit challenge_path(challenge_with_max_5_members)
      expect(page).to have_content 'Create Team'
    end
  end
end
