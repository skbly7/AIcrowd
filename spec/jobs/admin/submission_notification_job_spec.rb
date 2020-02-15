require 'rails_helper'
RSpec.describe Admin::SubmissionNotificationJob, type: :job, api: true do
  include ActiveJob::TestHelper

  let!(:submission) { create :submission }
  let!(:admin) { create :participant, :admin }

  before do
    admin.email_preferences.first.update(email_frequency: :every)
  end

  subject(:job) { described_class.perform_later(submission) }

  describe 'queues the job' do
    after do
      clear_enqueued_jobs
      clear_performed_jobs
    end

    it 'queues the job' do
      expect { job }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
    end

    it 'is placed on the default queue' do
      expect(described_class.new.queue_name).to eq('default')
    end

    it 'executes with no errors' do
      perform_enqueued_jobs { job }
    end
  end
end
