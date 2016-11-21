class EndChallengeJob
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { daily }

  def perform
    Challenge.where(status_cd: 'running').each do |challenge|
      if challenge.timeline.remaining_time_in_seconds == 0
        challenge.update!(status_cd: 'completed')
      end
    end
  end

end
