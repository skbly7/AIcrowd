require 'rails_helper'

describe ChallengesController, feature: true do
  describe '#show' do
    context 'when user is logged in as participant' do
      let(:participant) { create(:participant) }

      before { log_in participant }

      context 'when challenge does not have teams allowed' do
        let!(:challenge) { create(:challenge, :running, teams_allowed: false) }

        it 'renders only Participate button' do
          visit challenge_path(challenge)

          expect(page).to have_http_status 200
          expect(page).to have_current_path challenge_path(challenge)
          expect(page).to have_content 'Participate'
          expect(page).not_to have_content 'Create Team'
          expect(page).not_to have_content 'My Team'
        end
      end

      context 'when challenge has teams allowed' do
        let!(:challenge)             { create(:challenge, :with_rules, :running, teams_allowed: true) }
        let!(:challenge_participant) { create(:challenge_participant, challenge: challenge, participant: participant) }

        context 'when participant is not a part of team' do
          it 'renders only Create Team button' do
            visit challenge_path(challenge)

            expect(page).to have_http_status 200
            expect(page).to have_current_path challenge_path(challenge)
            expect(page).not_to have_content 'Participate'
            expect(page).to have_content 'Create Team'
            expect(page).not_to have_content 'My Team'
          end
        end

        context 'when participant is part of a team' do
          let!(:team)             { create(:team, challenge: challenge) }
          let!(:team_participant) { create(:team_participant, team: team, participant: participant) }

          it 'renders only My Team button' do
            visit challenge_path(challenge)

            expect(page).to have_http_status 200
            expect(page).to have_current_path challenge_path(challenge)
            expect(page).not_to have_content 'Participate'
            expect(page).not_to have_content 'Create Team'
            expect(page).to have_content 'My Team'
          end
        end
      end
    end
  end

  describe '#new' do
    context 'when user is logged in as participant' do
      let(:participant) { create(:participant) }

      before { log_in participant }

      it 'renders unauthorized flash' do
        visit new_challenge_path

        expect(page).to have_http_status 200
        expect(page).to have_current_path root_path
        expect(page).to have_content 'You are not authorised to access this page'
      end
    end

    context 'when user is logged in as organizer' do
      let(:organizer) { create(:participant, :organizer) }

      before { log_in organizer }

      it 'renders new challenge page' do
        visit new_challenge_path

        expect(page).to have_http_status 200
        expect(page).to have_current_path new_challenge_path
      end

      it 'allows to create challenge', js: true do
        visit new_challenge_path

        fill_in 'challenge_challenge', with: 'Created challenge title'
        click_on 'Create challenge'

        challenge = Challenge.find_by!(challenge: 'Created challenge title')

        expect(page).to have_current_path edit_challenge_path(challenge, step: :overview)
        expect(page).to have_content('Challenge created.')

        click_on 'challenge-edit-details-tab'

        expect(page).to have_field('challenge_challenge', with: 'Created challenge title')
      end
    end

    context 'when user is logged in as admin' do
      let!(:organizer) { create(:organizer) }
      let(:admin)      { create(:participant, :admin) }

      before { log_in admin }

      it 'renders new challenge page' do
        visit new_challenge_path

        expect(page).to have_http_status 200
        expect(page).to have_current_path new_challenge_path
      end

      it 'allows to create challenge', js: true do
        visit new_challenge_path

        fill_in 'challenge_challenge', with: 'Created challenge title'
        select organizer.organizer, from: 'challenge_organizer_id'
        click_on 'Create challenge'

        challenge = Challenge.find_by!(challenge: 'Created challenge title')

        expect(page).to have_current_path edit_challenge_path(challenge, step: :overview)
        expect(page).to have_content('Challenge created.')

        click_on 'challenge-edit-details-tab'

        expect(page).to have_field('challenge_challenge', with: 'Created challenge title')
      end
    end
  end

  describe '#edit' do
    let(:challenge) { create(:challenge) }

    context 'when user is logged in as participant' do
      let(:participant) { create(:participant) }

      before { log_in participant }

      it 'renders unauthorized flash' do
        visit edit_challenge_path(challenge)

        expect(page).to have_http_status 200
        expect(page).to have_current_path root_path
        expect(page).to have_content 'You are not authorised to access this page'
      end
    end

    context 'when user is logged in as admin' do
      let(:admin) { create(:participant, :admin) }

      before { log_in admin }

      it 'render challenge edit page' do
        visit edit_challenge_path(challenge)

        expect(page).to have_http_status 200
        expect(page).to have_current_path edit_challenge_path(challenge)
      end

      it 'allows to update challenge', js: true do
        visit edit_challenge_path(challenge)

        fill_in 'challenge_tagline', with: 'Updated challenge tagline'
        click_on 'Update challenge'

        expect(page).to have_current_path edit_challenge_path(challenge, step: :overview)

        click_on 'challenge-edit-details-tab'

        expect(page).to have_field('challenge_tagline', with: 'Updated challenge tagline')
      end
    end
  end
end
