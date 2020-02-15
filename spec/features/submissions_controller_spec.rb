require 'rails_helper'

describe SubmissionsController, feature: true do
  describe '#index' do
    let!(:challenge)                      { create(:challenge, :running) }
    let!(:submission)                     { create(:submission, challenge: challenge, grading_message: 'Submission Grading Message') }
    let!(:submission_without_participant) { create(:submission, challenge: challenge, participant: nil) }

    context 'when user is not logged in' do
      it 'renders submissions listing' do
        visit challenge_submissions_path(challenge)

        expect(page).to have_http_status 200
        expect(page).to have_current_path challenge_submissions_path(challenge)
        expect(page).to have_content('Submission Grading Message')
      end
    end

    context 'when user is logged in' do
      let(:admin) { create(:participant, :admin) }

      before { log_in admin }

      it 'renders submissions listing' do
        visit challenge_submissions_path(challenge)

        expect(page).to have_http_status 200
        expect(page).to have_current_path challenge_submissions_path(challenge)
        expect(page).to have_content('Submission Grading Message')
      end
    end
  end
end
