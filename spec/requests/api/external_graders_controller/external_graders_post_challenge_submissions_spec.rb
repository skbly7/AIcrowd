require 'rails_helper'

RSpec.describe Api::ExternalGradersController, type: :request do
  before do
    Timecop.freeze(DateTime.new(2017, 10, 30, 2, 2, 2, "+02:00"))
  end

  after do
    Timecop.return
  end

  let!(:organizer) do
    create :organizer,
           api_key: '3d1efc2332200314c86d2921dd33434c'
  end
  let!(:participation_terms) do
    create :participation_terms
  end
  let!(:challenge) do
    create :challenge,
           :running, organizer: organizer, post_challenge_submissions: true
  end
  let!(:challenge_rules) do
    create :challenge_rules,
           challenge: challenge
  end
  let!(:challenge_round) do
    create :challenge_round,
           challenge_id: challenge.id,
           active:       true,
           start_dttm:   5.weeks.ago,
           end_dttm:     4.weeks.ago
  end
  let!(:participant) do
    create :participant,
           api_key: '5762b9423a01f72662264358f071908c'
  end
  let!(:challenge_participant) do
    create :challenge_participant,
           challenge:   challenge,
           participant: participant
  end

  describe "POST /api/external_graders/ : create submission" do
    def valid_attributes
      { challenge_client_name: challenge.challenge_client_name,
        api_key:               participant.api_key,
        grading_status:        'graded',
        score:                 0.9763 }
    end

    context 'post challenge submission' do
      before do
        post '/api/external_graders/',
             params:  valid_attributes,
             headers: { 'Authorization': auth_header(organizer.api_key) }
      end

      it { expect(response).to have_http_status(:accepted) }

      it {
        expect(json(response.body)[:message])
        .to eq("Participant #{participant.name} scored")
      }

      it { expect(json(response.body)[:submission_id]).to be_a Integer }
      it { expect(json(response.body)[:submissions_remaining]).to eq(4) }
      it { expect(Submission.count).to eq(1) }
      it { expect(Submission.last.participant_id).to eq(participant.id) }
      it { expect(Submission.last.score).to eq(valid_attributes[:score]) }
      it { expect(Submission.last.grading_status_cd).to eq('graded') }
      it { expect(Submission.last.challenge.post_challenge_submissions).to eq(true) }
      it { puts Submission.last.created_at }
      it { puts ChallengeRound.last.end_dttm }
      # it { expect(Submission.last.post_challenge).to be true }
    end
  end # POST

  Timecop.return
end
