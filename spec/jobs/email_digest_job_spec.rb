require 'rails_helper'

RSpec.describe EmailDigestJob, type: :job, api: true do
  include ActiveJob::TestHelper

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end

  describe 'executes the daily digest' do
    let(:participant) do
      create :participant,
             email_frequency: :daily
    end

    subject(:job) { described_class.perform_later("digest_type" => "daily") }

    it 'queues the job' do
      expect { job }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
    end

    it 'is placed on the default queue' do
      expect(described_class.new.queue_name).to eq("digest")
    end

    it 'executes with no errors' do
      perform_enqueued_jobs { job }
    end
  end

  describe 'executes the weekly digest' do
    let(:participant) do
      create :participant,
             email_frequency: :weekly
    end

    subject(:job) { described_class.perform_later("digest_type" => "weekly") }

    it 'queues the job' do
      expect { job }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
    end

    it 'is placed on the default queue' do
      expect(described_class.new.queue_name).to eq('digest')
    end

    it 'executes with no errors' do
      perform_enqueued_jobs { job }
    end
  end

  describe 'admin - daily digest: submissions only' do
    let!(:participant) { create :participant, :admin }

    before do
      participant.email_preferences.first.update_columns(email_frequency: :every)
    end

    it 'does not receive submission info from 2 days ago' do
      Timecop.freeze(Time.now - 2.days)
      submission = FactoryBot.create :submission
      Timecop.return
      perform_enqueued_jobs { described_class.perform_later("digest_type" => "daily") }

      expect(MandrillMessage.count).to eq(0)
    end

    it 'receives submission info from 12 hours ago' do
      Timecop.freeze(Time.now - 12.hours)
      submission = FactoryBot.create :submission
      Timecop.return
      perform_enqueued_jobs { described_class.perform_later("digest_type" => "daily") }

      expect(MandrillMessage.count).to eq(1)
    end
  end

  describe 'admin - weekly digest: submissions only' do
    let!(:participant) { create :participant, :weekly, admin: true }

    it 'does not receive submission info from 8 days ago' do
      Timecop.freeze(Time.now - 8.days)
      submission = FactoryBot.create :submission
      Timecop.return
      perform_enqueued_jobs { described_class.perform_later("digest_type" => "weekly") }

      expect(MandrillMessage.count).to eq(0)
    end

    it 'receives submission info from 5 days ago' do
      Timecop.freeze(Time.now - 5.days)
      submission = FactoryBot.create :submission
      Timecop.return
      perform_enqueued_jobs { described_class.perform_later("digest_type" => "weekly") }

      expect(MandrillMessage.count).to eq(1)
    end
  end
end
