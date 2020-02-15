# frozen_string_literal: true

require 'rails_helper'

describe Challenges::TeamInvitationsController, '#create', type: :controller do
  render_views

  let!(:participant)                     { create(:participant) }
  let!(:invitee)                         { create(:participant) }
  let!(:member_of_other_abstract_team)   { create(:participant) }
  let!(:member_1_of_other_concrete_team) { create(:participant) }
  let!(:member_2_of_other_concrete_team) { create(:participant) }
  let!(:challenge)                       { create(:challenge) }
  let!(:team)                            { create(:team, challenge: challenge, participants: [participant]) }
  let!(:other_abstract_team)             { create(:team, challenge: challenge, participants: [member_of_other_abstract_team]) }
  let!(:other_concrete_team)             { create(:team, challenge: challenge, participants: [member_1_of_other_concrete_team, member_2_of_other_concrete_team]) }
  let!(:unknown_email)                   { FFaker::Internet.unique.email }

  def perform_request(team_name, invitee_name_or_email)
    # we parse an actual path instead of using shortcuts to ensure routes are working properly
    path   = challenge_team_invitations_path(challenge, team_name)
    params = Rails.application.routes.recognize_path(path, method: :post)
    post(params[:action], params: params.except(:controller, :action).merge(invitee: invitee_name_or_email))
  end

  def team_invitees_prev
    @team_invitees_prev || []
  end

  def team_invitee_added
    @team_invitee_added || invitee
  end

  def team_invitees_all
    team_invitees_prev + [team_invitee_added]
  end

  shared_examples 'success' do
    it 'has the right invitees' do
      expect(team.team_invitations.invitees_a).to contain_exactly(*team_invitees_all)
    end

    it 'has persisted email invitations correctly' do
      num_email_invites = team_invitees_all.select { |x| x.is_a?(EmailInvitation) }.size
      expect(EmailInvitation.count).to eq(num_email_invites)
    end

    it 'reports success' do
      msg = I18n.t(:success, scope: %i[helpers teams create_invitation_flash])
      expect(flash[:success]).to eq(msg)
    end

    it 'does not report error' do
      expect(flash[:error]).not_to be
    end

    it 'redirects to team page' do
      expect(response).to redirect_to(challenge_team_url(challenge, team))
    end
  end

  shared_examples 'failure' do |error_flash_symbol|
    it 'has no unexpected invitees' do
      expect(team.team_invitations.invitees_a).to contain_exactly(*team_invitees_prev)
    end

    it 'did not add an email' do
      expect(EmailInvitation.count).to eq(0)
    end

    it 'does not report success to user' do
      expect(flash[:success]).not_to be
    end

    it 'reports error to user' do
      if error_flash_symbol
        msg = I18n.t(error_flash_symbol, scope: %i[helpers teams create_invitation_flash])
        expect(flash[:error]).to match(msg)
      else
        expect(flash[:error]).to be
      end
    end

    it 'redirects to team page' do
      expect(response).to redirect_to(challenge_team_url(challenge, team))
    end
  end

  context 'while logged out' do
    before { perform_request(team.name, invitee.name) }

    it { expect(team.team_invitations.invitees_a).to eq([]) }
    it { expect(EmailInvitation.count).to eq(0) }
    it { expect(flash[:alert]).to be }
    it { expect(response).to redirect_to(new_participant_session_url) }
  end

  context 'while logged in' do
    before { sign_in(participant) }

    context 'when not team organizer' do
      let!(:organizer) { create :participant }

      before do
        team.team_participants.first.update(participant_id: organizer.id)
        perform_request(team.name, invitee.name)
      end

      include_examples 'failure', :participant_not_organizer
    end

    context 'when teams are frozen' do
      before do
        team.challenge.update!(status: :completed)
        perform_request(team.name, invitee.name)
      end

      include_examples 'failure', :challenge_teams_frozen
    end

    context 'when team is full' do
      let!(:dummy) { create :participant }

      before { team.challenge.update!(max_team_participants: 2) }

      context 'due to max members' do
        before do
          team.team_participants.create!(participant: dummy)
          perform_request(team.name, invitee.name)
        end

        include_examples 'failure', :team_full
      end

      context 'due to max invitations' do
        before do
          team.team_invitations.create!(invitor: participant, invitee: dummy)
          @team_invitees_prev = [dummy]
          perform_request(team.name, invitee.name)
        end

        include_examples 'failure', :team_full
      end
    end

    context 'passing name' do
      context 'of same case' do
        before { perform_request(team.name, invitee.name) }

        include_examples 'success'
      end

      context 'of different case' do
        before { perform_request(team.name.swapcase, invitee.name.swapcase) }

        include_examples 'success'
      end

      context 'where invitee is on a different abstract team' do
        before do
          perform_request(team.name, member_of_other_abstract_team.name)
          @team_invitee_added = member_of_other_abstract_team
        end

        include_examples 'success'
      end

      context 'where invitee is on the team already' do
        context 'as a member' do
          before do
            team.team_participants.create!(participant: invitee)
            perform_request(team.name, invitee.name)
          end

          include_examples 'failure', :invitee_on_this_team_confirmed
        end

        context 'as a pending invitation' do
          before do
            team.team_invitations.create!(invitor: participant, invitee: invitee)
            @team_invitees_prev = [invitee]
            perform_request(team.name, invitee.name)
          end

          include_examples 'failure', :invitee_on_this_team_pending
        end
      end

      context 'where invitee is on a different concrete team' do
        before { perform_request(team.name, member_2_of_other_concrete_team.name) }

        include_examples 'failure', :invitee_on_other_team
      end

      context 'where invitee name is unknown' do
        before { perform_request(team.name, FFaker::Name.unique.first_name) }

        include_examples 'failure', :invitee_nil
      end
    end

    context 'passing dotted names' do
      let!(:invitee_dot) { build :participant, :dotted_name }
      let!(:team_dot) { build :team, :dotted_name }

      before do
        invitee.update!(name: invitee_dot.name)
        team.update!(name: team_dot.name)
      end

      context 'of same case' do
        before { perform_request(team.name, invitee.name) }

        include_examples 'success'
      end

      context 'of different case' do
        before { perform_request(team.name.swapcase, invitee.name.swapcase) }

        include_examples 'success'
      end
    end

    context 'passing email' do
      context 'of existing user' do
        context 'using same case' do
          before { perform_request(team.name, invitee.email) }

          include_examples 'success'
        end

        context 'using different case' do
          before { perform_request(team.name, invitee.email.swapcase) }

          include_examples 'success'
        end
      end

      context 'of unknown user' do
        before do
          perform_request(team.name, unknown_email)
          @team_invitee_added = EmailInvitation.last
        end

        include_examples 'success'
      end

      context 'where invitee is on the team already' do
        context 'as a member' do
          before do
            team.team_participants.create!(participant: invitee)
            perform_request(team.name, invitee.email)
          end

          include_examples 'failure', :invitee_on_this_team_confirmed
        end

        context 'as a pending invitation' do
          before do
            team.team_invitations.create!(invitor: participant, invitee: invitee)
            @team_invitees_prev = [invitee]
            perform_request(team.name, invitee.email)
          end

          include_examples 'failure', :invitee_on_this_team_pending
        end
      end
    end
  end
end
