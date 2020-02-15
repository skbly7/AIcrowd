class MigrateUserJob < ApplicationJob
  queue_as :default

  def perform(crowdai_id:, aicrowd_id:)
    MigrateUserService.new(crowdai_id: crowdai_id, aicrowd_id: aicrowd_id).migrate_user
  end
end
