require 'rails_helper'

RSpec.describe SubmissionGradedNotificationJob, type: :job do
  include ActiveJob::TestHelper

  let!(:participant) { create :participant }
  let!(:challenge) { create :challenge, :running }
  let(:submission) do
    create :submission,
           challenge:   challenge,
           participant: participant
  end
  let!(:admin) { create :participant, :admin }
  let!(:email_preference1) do
    create :email_preference,
           email_frequency: :every,
           participant:     participant
  end
  let!(:email_preference2) do
    create :email_preference,
           email_frequency: :every,
           participant:     admin
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end

  describe 'queues the job' do
    subject(:job) { described_class.perform_later(submission) }

    it 'queues the job' do
      expect do
        job
      end.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
    end

    it 'is placed on the default queue' do
      expect(described_class.new.queue_name).to eq('default')
    end

    it 'executes with no errors' do
      perform_enqueued_jobs { job }
    end
  end

  describe 'supporting methods' do
    subject(:job) { described_class.new }

    it '#admin_ids' do
      expect(job.admin_ids).to match_array([admin.id])
    end

    it '#recipient_ids' do
      expect(job.recipient_ids(submission)).to match_array([admin.id, participant.id])
    end
  end
end
