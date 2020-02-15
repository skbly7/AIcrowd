require 'rails_helper'

describe 'Participant visits migration page from email' do
  let!(:participant) { create :participant }
  let!(:migrated_challenge) { create :challenge, challenge: 'migrated_challenge', status: 'completed' }
  let!(:migrated_challenge_round) { create :challenge_round, challenge: migrated_challenge }
  let!(:migrated_submission) { create :submission, challenge_round: migrated_challenge_round, participant: nil, score: 100, challenge: migrated_challenge }
  let!(:data_to_encrypt) { { id: 1, name: 'TestFox', email: 'email@example.com' }.to_json }
  let!(:encrypted_data) { setup_crowdai_migration data_to_encrypt }

  before { login_as(participant) }

  it "renders page successfully" do
    get crowdai_migration_path(data: encrypted_data)
    expect(response).to render_template(:new)
  end

  context 'Confirms migration' do
    context 'Successful Migration' do
      before do
        MigrationMapping.create!(
          source_type:            'Submission',
          source_id:              migrated_submission.id,
          crowdai_participant_id: 1
        )
      end
      it "redirect with success flash and migration queued" do
        post crowdai_migration_save_path(data: encrypted_data)
        follow_redirect!
        expect(response.body).to include("We have received and processing your migration request. Welcome to AIcrowd!")
        expect(MigrateUserJob).to have_been_enqueued.with(crowdai_id: 1, aicrowd_id: participant.id)
      end
    end
    context 'Fails unless data is present' do
      it "redirect with error flash" do
        post crowdai_migration_save_path(data: {})
        follow_redirect!
        expect(response.body).to include("Error while processing, contact help@aicrowd.com")
      end
    end
  end

  def setup_crowdai_migration(data_to_encrypt)
    # Setup RSA Keys
    rsa_key = OpenSSL::PKey::RSA.generate(2048)
    # Setup cipher
    cipher    = OpenSSL::Cipher.new('AES-256-CBC')
    cipherkey = cipher.random_key
    iv        = cipher.random_iv

    cipher.encrypt
    cipher.key = cipherkey
    cipher.iv  = iv

    ciphertext    = cipher.update(data_to_encrypt) + cipher.final
    en_cipherkey  = Base64.urlsafe_encode64(rsa_key.private_encrypt(cipherkey))
    en_iv         = Base64.urlsafe_encode64(iv)
    en_ciphertext = Base64.urlsafe_encode64(ciphertext)

    ENV['CROWDAI_PARTICIPANT_MIGRATION_PUBKEY'] = rsa_key.public_key.to_s
    "#{en_cipherkey}~#{en_iv}~#{en_ciphertext}"
  end
end
