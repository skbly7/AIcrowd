require 'rails_helper'

describe Challenge do
  context 'methods' do
    describe 'validate markdown fields' do
      let(:challenge) { create :challenge, :running }

      it 'description' do
        challenge.update!(description_markdown: '### The description')
        expect(challenge.description).to eq("<h3 id=\"the-description\">The description</h3>\n")
      end

      it 'evaluation' do
        challenge.update!(evaluation_markdown: '# An evaluation')
        expect(challenge.evaluation).to eq("<h1 id=\"an-evaluation\">An evaluation</h1>\n")
      end

      it 'rules' do
        challenge.update!(rules_markdown: "Some *rules*")
        expect(challenge.rules).to eq("<p>Some <em>rules</em></p>\n")
      end

      it 'prizes' do
        challenge.update!(prizes_markdown: "# Prizes are described here.")
        expect(challenge.prizes).to eq("<h1 id=\"prizes-are-described-here\">Prizes are described here.</h1>\n")
      end

      it 'resources' do
        challenge.update!(resources_markdown: "# Helpful resources")
        expect(challenge.resources).to eq("<h1 id=\"helpful-resources\">Helpful resources</h1>\n")
      end

      it 'dataset_description' do
        challenge.update!(dataset_description_markdown: "# Dataset description")
        expect(challenge.dataset_description).to eq("<h1 id=\"dataset-description\">Dataset description</h1>\n")
      end

      it 'submission_instructions' do
        challenge.update!(submission_instructions_markdown: "## Submission instructions")
        expect(challenge.submission_instructions).to eq("<h2 id=\"submission-instructions\">Submission instructions</h2>\n")
      end
      # it 'winner_description' do
      #  challenge.update!(winner_description_markdown: '## A Winner!!')
      #  expect(challenge.winner_description).to eq("<h2 id=\"a-winner\">A Winner!!</h2>\n")
      # end
    end

    describe 'after_initialize' do
      it 'sets submission information defaults' do
        challenge = create(:challenge, :running)
        expect(challenge.submission_license).to eq("Please upload your submissions and include a detailed description of the methodology, techniques and insights leveraged with this submission. After the end of the challenge, these comments will be made public, and the submitted code and models will be freely available to other AIcrowd participants. All submitted content will be licensed under Creative Commons (CC).")
      end
    end

    describe "friendly_id" do
      it 'updates the slug when the challenge title changes' do
        challenge           = create(:challenge, :running)
        challenge.challenge = 'a new challenge title'
        challenge.save!
        expect(challenge.slug).to eq('a-new-challenge-title')
      end
    end

    describe '#current_round' do
      context 'single open round' do
        let(:challenge) { create :challenge, :running }

        it { expect(challenge.current_round.round_status_cd).to eq('current') }
        it { expect(challenge.current_round.active).to be true }
        it { expect(challenge.current_round.challenge_id).to eq(challenge.id) }
      end

      context 'previous and current round' do
        let(:challenge) { create :challenge, :previous_round }

        it { expect(challenge.current_round.round_status_cd).to eq('current') }
        it { expect(challenge.current_round.active).to be true }
        it { expect(challenge.current_round.challenge_id).to eq(challenge.id) }
      end
    end

    describe '#round_open?' do
      context 'single open round' do
        let(:challenge) { create :challenge, :running }

        it { expect(challenge.round_open?).to be true }
      end

      context 'previous and current round' do
        let(:challenge) { create :challenge, :previous_round }

        it { expect(challenge.round_open?).to be true }
      end
    end

    describe '#previous_round' do
      context 'single open round' do
        let(:challenge) { create :challenge, :running }

        it { expect(challenge.previous_round).to be_nil }
      end

      context 'previous and current round' do
        let(:challenge) { create :challenge, :previous_round }

        it { expect(challenge.previous_round.challenge_round).to eq('round 1') }
        it { expect(challenge.current_round.challenge_round).to eq('round 2') }
      end
    end
  end
end
