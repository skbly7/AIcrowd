require 'rails_helper'

describe MarkdownEditorPolicy do
  subject { described_class.new(participant, nil) }

  context 'for a public participant' do
    let(:participant) { nil }

    it { is_expected.to forbid_action(:show) }
    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:create) }
    it { is_expected.to forbid_action(:new) }
    it { is_expected.to forbid_action(:update) }
    it { is_expected.to forbid_action(:edit) }
    it { is_expected.to forbid_action(:destroy) }
    it { is_expected.to forbid_action(:presign) }
  end

  context 'for a participant' do
    let(:participant) { build(:participant) }

    it { is_expected.to forbid_action(:show) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to forbid_action(:create) }
    it { is_expected.to forbid_action(:new) }
    it { is_expected.to forbid_action(:update) }
    it { is_expected.to forbid_action(:edit) }
    it { is_expected.to forbid_action(:destroy) }
    it { is_expected.to permit_action(:presign) }
  end
end
