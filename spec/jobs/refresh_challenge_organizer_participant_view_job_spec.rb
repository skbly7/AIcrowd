require 'rails_helper'

RSpec.describe RefreshChallengeOrganizerParticipantViewJob, type: :job do
  include ActiveJob::TestHelper

  let!(:organizer) { create :organizer }
  let!(:participant) do
    create :participant, organizer_id: organizer.id
  end

  let(:clef_task) { create :clef_task }
  let(:clef_organizer) do
    create :organizer, :clef, clef_task_id: clef_task.id
  end
  let(:challenge) do
    create :challenge, organizer_id: clef_organizer.id
  end
  let(:participant2) do
    create :participant, organizer_id: clef_organizer.id
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end

  describe 'queues the job' do
    subject(:job) { described_class.perform_later }

    it 'queues the job' do
      expect { job }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
    end

    it 'is placed on the notifications queue' do
      expect(described_class.new.queue_name).to eq('default')
    end

    it 'executes with no errors' do
      perform_enqueued_jobs { job }
    end
  end
end
