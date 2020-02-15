# require 'rails_helper'
#
# feature 'Terms should be accepted before Team Invitations are accepted' do
#
#   let!(:challenge) { create :challenge, :running, teams_allowed: true }
#   let!(:challenge_rules) { create :challenge_rules, challenge: challenge }
#   let!(:participation_terms) { create :participation_terms }
#
#   let!(:participant_accepted) { create :participant }
#   let!(:participant_not_accepted) { create :participant }
#
#   let!(:challenge_participant) { create :challenge_participant, challenge: challenge, participant: participant_accepted }
#   let!(:team) { create :team, challenge: challenge, participants: [participant_accepted] }
#
#   describe "Invitation URL should redirect to terms or rules page" do
#     scenario "Redirects to Challenge Rules" do
#       invitation = team.team_invitations.new(invitor: participant_accepted, invitee: participant_not_accepted)
#       invitation.save!
#       log_in(participant_not_accepted)
#       visit team_invitation_acceptances_path(invitation)
#       expect(current_path).to eq(polymorphic_path([challenge, challenge.current_challenge_rules]))
#       check 'I have read and agree to the challenge rules (required)'
#       click_on "Save"
#       expect(current_path).to eq(team_invitation_acceptances_path(invitation))
#     end
#
#     scenario "Redirects to Participation Terms" do
#       invitation = team.team_invitations.new(invitor: participant_accepted, invitee: participant_not_accepted)
#       invitation.save
#
#       participant_not_accepted.participation_terms_accepted_date =  nil
#       participant_not_accepted.participation_terms_accepted_version = nil
#       participant_not_accepted.save
#
#       log_in(participant_not_accepted)
#       visit team_invitation_acceptances_path(invitation)
#       expect(current_path).to eq(polymorphic_path([challenge, ParticipationTerms.current_terms]))
#       check 'I have read and agree to the participation terms (required)'
#       click_on 'Save'
#       expect(current_path).to eq(polymorphic_path([challenge, challenge.current_challenge_rules]))
#       check 'I have read and agree to the challenge rules (required)'
#       click_on "Save"
#       expect(current_path).to eq(team_invitation_acceptances_path(invitation))
#     end
#
#   end
# end
