require 'rails_helper'

describe MandrillMessage do
  context 'methods' do
    let!(:man) { create :mandrill_message }

    it { expect(man.status).to eq('sent') }
    it { expect(man.reject_reason).to be_nil }
    it { expect(man.subject).to eq("New discussion comment") }
    it { expect(man.from_name).to eq("AIcrowd") }
    it { expect(man.from_email).to eq("no-reply@aicrowd.com") }
    it { expect(man.email_array).to eq(["micah@satterfieldzulauf.name"]) }
    it { expect(man.merge_var('NAME')).to eq("participant_1456@example.com") }
  end
end
