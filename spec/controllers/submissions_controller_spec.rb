require 'rails_helper'

describe SubmissionsController, type: :controller do
  render_views

  let!(:submissions)           { create_list(:submission, 3, challenge: challenge, participant: participant, grading_status_cd: 'graded') }
  let!(:meta)                  { create(:submission, :with_meta, challenge: challenge, participant: participant, grading_status_cd: 'graded') }
  let!(:challenge_rules)       { create(:challenge_rules, challenge: challenge) }
  let!(:participation_terms)   { create(:participation_terms) }
  let(:participant)            { create(:participant) }
  let!(:challenge_participant) { create(:challenge_participant, challenge: challenge, participant: participant) }

  let(:all_submissions) { (submissions + [meta]).reverse }
  let(:challenge)       { create(:challenge, :running, submissions_page: true) }

  describe 'GET #index' do
    context 'login' do
      before do
        sign_in participant
        get :index, params: { challenge_id: challenge.id }
      end

      it { expect(assigns(:submissions)).to eq all_submissions }
      it { expect(response).to render_template :index }
    end

    context 'no login' do
      before { get :index, params: { challenge_id: challenge.id } }

      it { expect(assigns(:submissions)).to eq all_submissions }
      it { expect(response).to render_template :index }
    end
  end

  describe 'GET #show' do
    let(:submission) { submissions.first }

    before { sign_in participant }

    context do
      before { get :show, params: { challenge_id: challenge.id, id: submission.id } }

      it { expect(assigns(:submission)).to eq submission }
      it { expect(response).to render_template :show }
    end

    context 'renders with meta' do
      before { get :show, params: { challenge_id: meta.challenge_id, id: meta.id } }

      it { expect(assigns(:submission)).to eq meta }
      it { expect(response).to render_template :show }
    end
  end
end
