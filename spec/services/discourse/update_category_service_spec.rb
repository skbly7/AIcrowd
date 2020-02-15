require 'rails_helper'

describe Discourse::UpdateCategoryService do
  subject { described_class.new(challenge: challenge) }

  let(:challenge) { create(:challenge) }

  describe '#call' do
    context 'when discourse ENV variables are missing' do
      before { ENV.stub(:[]).with('DISCOURSE_DOMAIN_NAME').and_return('') }

      it 'returns failure' do
        result = subject.call

        expect(result.success?).to eq false
        expect(result.value).to eq 'DiscourseApi client couldn\'t be properly initialized.'
      end
    end

    context 'when discourse ENV variables are set' do
      context 'when challenge complies with discourse category validations' do
        let(:challenge) { create(:challenge, challenge: 'Short Challenge Name', discourse_category_id: 30) }

        it 'returns success and assigns discourse_category_id to challenge' do
          result = VCR.use_cassette('discourse_api/update/success') do
            subject.call
          end

          expect(result.success?).to eq true
        end
      end

      context 'when challenge name is to long' do
        let(:challenge) do
          create(
            :challenge,
            challenge: 'Way To Long Chalenge Name - aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
            discourse_category_id: 30
          )
        end

        it 'truncates dicourse category name and returns success' do
          result = VCR.use_cassette('discourse_api/update/success_truncated_category_name') do
            subject.call
          end

          expect(result.success?).to eq true
        end
      end

      context 'when discourse category already exists' do
        let(:challenge) { create(:challenge, challenge: 'Discourse Category Name That Exists', discourse_category_id: 30) }

        it 'generates new category name and returns success' do
          result = VCR.use_cassette('discourse_api/update/success_generated_new_category_name') do
            subject.call
          end

          expect(result.success?).to eq true
        end
      end

      context 'when discourse API is unavailable' do
        let(:challenge) { create(:challenge, challenge: 'Short Challenge Name', discourse_category_id: 30) }

        before do
          allow_any_instance_of(DiscourseApi::Client).to receive(:request).and_raise(::DiscourseApi::Error)
        end

        it 'returns failure' do
          result = subject.call

          expect(result.success?).to eq false
          expect(result.value).to eq 'Discourse API is unavailable'
        end
      end
    end
  end
end
