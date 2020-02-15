class CrowdaiMigrationController < ApplicationController
  before_action :set_crowdai_params, only: [:create]
  after_action :track_action

  def new
    @data = params[:data]
    session['participant_return_to'] = request.original_fullpath unless @current_participant
    redirect_to(root_path, flash: { error: 'Invalid link, contact help@aicrowd.com' }) if @data.nil?
  end

  def create
    return redirect_to(root_path, flash: { error: 'Error while processing, contact help@aicrowd.com' }) if @cid.nil?

    @migrate_service = MigrateUserService.new(crowdai_id: @cid, aicrowd_id: current_participant.id)

    return redirect_to(root_path, flash: { error: 'CrowdAI account associated with this link is already migrated' }) if @migrate_service.check_migrated

    return redirect_to(root_path, flash: { error: 'No data found for your CrowdAI account, please contact help@aicrowd.com' }) unless MigrationMapping.exists?(crowdai_participant_id: @cid)

    MigrateUserJob.perform_later(crowdai_id: @cid, aicrowd_id: current_participant.id)

    redirect_to(root_path, flash: { success: 'We have received and processing your migration request. Welcome to AIcrowd!' })
  end

  private

  def set_crowdai_params
    safely do
      data = params[:data]
      return unless data

      rsa_key                   = OpenSSL::PKey::RSA.new(ENV['CROWDAI_PARTICIPANT_MIGRATION_PUBKEY'])
      cipherkey, iv, ciphertext = data.split('~').map { |x| Base64.urlsafe_decode64(x) }
      cipher                    = OpenSSL::Cipher.new('AES-256-CBC')
      cipher.decrypt
      cipher.key = rsa_key.public_decrypt(cipherkey)
      cipher.iv  = iv
      plaintext  = cipher.update(ciphertext) + cipher.final
      data_hash  = JSON.parse(plaintext).symbolize_keys
      @cid       = data_hash[:id]
    end
  end
end
