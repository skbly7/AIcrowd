require "rails_helper"

describe EmailDigestMailer, type: :mailer do
  let(:challenge) { create :challenge, :running }
  let(:other_participant) do
    create :participant, :every_email
  end
  let(:submission) { create :submission, challenge: challenge }

  context 'methods' do
    before do
      Timecop.freeze(Time.now)
    end

    after do
      Timecop.return
    end

    describe '#set_start_dttm' do
      it 'daily' do
        start_dttm = described_class.new.set_start_dttm('daily')
        expect(start_dttm).to eq(Time.now - 24.hours)
      end

      it 'weekly' do
        start_dttm = described_class.new.set_start_dttm('weekly')
        expect(start_dttm).to eq(Time.now - 7.days)
      end
    end

    describe '#build_subject' do
      it 'daily' do
        subj = described_class.new.build_subject('daily')
        expect(subj).to eq("[AIcrowd] Daily digest")
      end

      it 'weekly' do
        subj = described_class.new.build_subject('weekly')
        expect(subj).to eq("[AIcrowd] Weekly digest")
      end
    end

    describe '#build_body' do
      let(:submissions)  { Submission.all }
      let!(:participant) { create :participant, :daily }

      it 'daily' do
        body = described_class.new.build_body(participant, 'daily', submissions)
        expect(body).to be_a_valid_html_fragment
      end

      it 'weekly' do
        body = described_class.new.build_body(participant, 'weekly', submissions)
        expect(body).to be_a_valid_html_fragment
      end
    end

    describe '#body_header' do
      it 'daily' do
        header = described_class.new.body_header('daily')
        expect(header).to eq("<div>Here's a daily summary of activity in AIcrowd.</div>")
      end

      it 'weekly' do
        header = described_class.new.body_header('weekly')
        expect(header).to eq("<div>Here's a weekly summary of activity in AIcrowd.</div>")
      end
    end

    describe '#submissions' do
    end

    describe '#render_submissions' do
    end
  end
end
