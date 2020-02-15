class MigrateUserService
  def initialize(crowdai_id:, aicrowd_id:)
    @old_id = crowdai_id
    @new_id = aicrowd_id
  end

  def check_migrated
    MigrationMapping.where(crowdai_participant_id: @old_id, source_type: 'Participant').count.positive?
  end

  def migrate_user
    raise "User Already Migrated" if check_migrated

    ActiveRecord::Base.transaction do
      update_migration_mappings(@new_id)
      MigrationMapping.create!(crowdai_participant_id: @old_id, source_id: @new_id, source_type: 'Participant')
    end
  end

  def undo_migration
    user_migration = MigrationMapping.where(crowdai_participant_id: @old_id, source_id: @new_id, source_type: 'Participant').first
    raise "User Not Migrated" if user_migration.nil?

    ActiveRecord::Base.transaction do
      update_migration_mappings(nil)
      user_migration.destroy
    end
  end

  private

  def get_migration_mappings
    models             = ['Submission', 'ChallengeParticipant', 'ParticipantClefTask', 'Vote', 'Follow']
    migration_mappings = []
    models.each do |model|
      migration_mappings << MigrationMapping.where(crowdai_participant_id: @old_id, source_type: model)
    end
    migration_mappings
  end

  def update_migration_mappings(aicrowd_id)
    get_migration_mappings.each do |migration_mapping|
      model  = migration_mapping['source_type'].constantize
      object = model.where(id: migration_mapping['source_id']).first
      object&.update(participant_id: aicrowd_id)
      next unless model == ChallengeParticipant

      object.challenge.challenge_rounds.each do |challenge_round|
        CalculateLeaderboardJob.perform_later(challenge_round_id: challenge_round.id)
      end
    end
  end
end
