require 'open-uri'

$list_of_failed_files = []

def custom_openfile(url_to_file)
  # https://twin.github.io/improving-open-uri/
  uri = URI.parse(URI.escape(url_to_file))
  puts uri
  begin
    io = uri.open
  rescue OpenURI::HTTPError => e
    $list_of_failed_files << url_to_file
    puts e
    return nil
  end

  downloaded = Tempfile.new([File.basename(uri.path), File.extname(uri.path)])

  if io.is_a?(Tempfile)
    FileUtils.mv io.path, downloaded.path
  else # StringIO
    Encoding.default_internal = io.string.encoding
    File.write(downloaded.path, io.string)
  end

  File.extname(downloaded.path)
  downloaded
end


# Turn off logger
#old_logger = ActiveRecord::Base.logger
#ActiveRecord::Base.logger = nil

# Fetch objects from the Saved Json Files
organizers = JSON.parse(File.read('db/crowdai_aicrowd_data_migration/organizers.json'))['organizers']
challenges = JSON.parse(File.read('db/crowdai_aicrowd_data_migration/challenges.json'))['challenges']
challenge_rounds = JSON.parse(File.read('db/crowdai_aicrowd_data_migration/challenge_rounds.json'))['challenge_rounds']
submissions = JSON.parse(File.read('db/crowdai_aicrowd_data_migration/submissions.json'))['submissions']
challenge_participants = JSON.parse(File.read('db/crowdai_aicrowd_data_migration/challenge_participants.json'))['challenge_participants']
clef_tasks = JSON.parse(File.read('db/crowdai_aicrowd_data_migration/clef_tasks.json'))['clef_tasks']
participant_clef_tasks = JSON.parse(File.read('db/crowdai_aicrowd_data_migration/participant_clef_tasks.json'))['participant_clef_tasks']
task_dataset_files = JSON.parse(File.read('db/crowdai_aicrowd_data_migration/task_dataset_files.json'))['task_dataset_files']

models = [Organizer, Challenge, ChallengeRound, Submission, ChallengeParticipant, TaskDatasetFile, ParticipantClefTask, ClefTask]

models.each do |model|
  ActiveRecord::Base.connection.reset_pk_sequence!(model.table_name)
end


# For each Organizer 'org'
organizers.each do |org|
  next if MigrationMapping.where(crowdai_participant_id: org['id'], source_type: 'Organizer').count.positive?

  ActiveRecord::Base.transaction do
    # Remove ID from Hash so that we get a new ID

    next if org['id'].nil?
    org_old_id = org['id']
    org.delete("id")
    # Add Tagline as it is needed
    org['tagline'] ||= org['organizer']
    # Create a new organizer from Hash
    loop_organizer = Organizer.create!(org)

    if org["image_file"].present?
      loop_organizer.image_file = custom_openfile("https://dnczkxd1gcfu5.cloudfront.net/images/organizers/image_file/#{org_old_id}/#{org['image_file']}")
      loop_organizer.save!
    end

    MigrationMapping.create!(
        source_type: 'Organizer',
        source_id: loop_organizer.id,
        crowdai_participant_id: org_old_id
    )

    # Select all the challenges for org
    selected_chals = challenges.select { |c| c['organizer_id'] == org_old_id }
    selected_clef_tasks = clef_tasks.select { |clt| clt['organizer_id'] == org_old_id }

    selected_clef_tasks.each do |clef_task|

      next if clef_task['id'].nil?
      clef_task_old_id = clef_task["id"]
      clef_task.delete("id")
      clef_task["organizer_id"] = loop_organizer.id
      loop_clef_task = ClefTask.create!(clef_task)

      if clef_task["eua_file"].present?
        loop_clef_task.eua_file = custom_openfile("https://dnczkxd1gcfu5.cloudfront.net/EUAs/clef_task/eua_file/#{clef_task_old_id}/#{clef_task['eua_file']}")
        loop_clef_task.save!
      end

      MigrationMapping.create!(
          source_type: 'ClefTask',
          source_id: loop_clef_task.id,
          crowdai_participant_id: clef_task_old_id
      )

      selected_pcts = participant_clef_tasks.select { |pct| pct['clef_task_id'] == clef_task_old_id }
      selected_pcts.each do |pct|
        next if pct['id'].nil?
        pct_old_id = pct["id"]
        pct.delete("id")
        pct.delete("participant_id")
        pct["clef_task_id"] = loop_clef_task.id

        loop_pct = ParticipantClefTask.create!(pct)

        if pct["eua_file"].present?
          loop_pct.eua_file = custom_openfile("https://dnczkxd1gcfu5.cloudfront.net/participant_euas/participant_clef_task/eua_file/#{pct_old_id}/#{pct['eua_file']}")
          loop_pct.save!
        end

        MigrationMapping.create!(
            source_type: 'ParticipantClefTask',
            source_id: loop_pct.id,
            crowdai_participant_id: pct_old_id
        )
      end

      selected_tdfs = task_dataset_files.select { |tdf| tdf['clef_task_id'] == clef_task_old_id }
      selected_tdfs.each do |tdf|
        next if tdf["id"].nil?
        tdf_old_id = tdf["id"]
        tdf.delete("id")
        tdf["clef_task_id"] = loop_clef_task.id
        loop_tdf = TaskDatasetFile.create!(tdf)

        MigrationMapping.create!(
            source_type: 'TaskDatasetFile',
            source_id: loop_tdf.id,
            crowdai_participant_id: tdf_old_id
        )
      end
    end

    selected_chals.each do |chal|
      next if chal["id"].nil?
      chal_old_id = chal["id"]
      chal.delete("id")
      chal.delete("featured_sequence")
      chal.delete("submission_count")
      chal["organizer_id"] = loop_organizer.id
      chal["hidden_challenge"] = true
      chal["prize_cash"] = ""
      chal["prize_academic"] = ""
      chal["prize_misc"] = ""
      chal["description_markdown"] = "#{chal["description_markdown"]}\n\n###Evaluation criteria\n#{chal["evaluation_markdown"]}\n\n###Resources\n\n#{chal["resources_markdown"]}\n\n###Prizes\n\n#{chal["prizes_markdown"]}\n\n###Datasets License\n\n#{chal["license_markdown"]}"
      chal["teams_allowed"] = false

      if !chal["clef_task_id"].nil? and chal["clef_challenge"] == true
        old_ct_id = chal["clef_task_id"]
        chal["clef_task_id"] = MigrationMapping.where(
            source_type: 'ClefTask',
            crowdai_participant_id: old_ct_id
        ).first&.source_id
      end

      # create a new challenge
      Challenge.skip_callback(:create, :after, :init_discourse)
      begin
        loop_challenge = Challenge.create!(chal)
      rescue ActiveRecord::RecordInvalid
        chal["challenge_client_name"] = "challenge_#{SecureRandom.hex}"
        loop_challenge = Challenge.create!(chal)
      end

      ChallengeRules.create!({challenge_id: loop_challenge.id, terms_markdown: chal['rules_markdown']})

      if chal["image_file"].present?
        loop_challenge.image_file = custom_openfile("https://dnczkxd1gcfu5.cloudfront.net/images/challenges/image_file/#{chal_old_id}/#{chal['image_file']}")
        loop_challenge.save!
      end
      Challenge.set_callback(:create, :after, :init_discourse)

      MigrationMapping.create!(
          source_type: 'Challenge',
          source_id: loop_challenge.id,
          crowdai_participant_id: chal_old_id
      )

      # Select all rounds for current challenge
      selected_chal_rounds = challenge_rounds.select { |cr| cr['challenge_id'] == chal_old_id }

      selected_chal_rounds.each do |chal_round|
        next if chal_round["id"].nil?
        old_chal_round_id = chal_round["id"]
        chal_round.delete("id")
        chal_round["challenge_id"] = loop_challenge.id
        chal_round["submission_limit"] = 5
        chal_round["submission_limit_period"] = "day"

        if chal_round["secondary_sort_order_cd"].blank?
          chal_round["secondary_sort_order_cd"] = "ascending"
        end

        loop_challenge_round = ChallengeRound.create!(chal_round)

        selected_chal_participants = challenge_participants.select { |cp| cp['challenge_id'] == chal_old_id }

        MigrationMapping.create!(
            source_type: 'ChallengeRound',
            source_id: loop_challenge_round.id,
            crowdai_participant_id: old_chal_round_id
        )

        selected_chal_participants.each do |chal_participant|
          next if chal_participant["participant_id"].nil?
          old_participant_id = chal_participant["participant_id"]
          chal_participant.delete("id")
          chal_participant.delete("participant_id")
          chal_participant["challenge_id"] = loop_challenge.id
          chal_participant["name"] = "Unknown User"

          loop_challenge_participant = ChallengeParticipant.create!(chal_participant)

          MigrationMapping.create!(
              source_type: 'ChallengeParticipant',
              source_id: loop_challenge_participant.id,
              crowdai_participant_id: old_participant_id
          )
        end

        selected_submissions = submissions.select { |s| s['challenge_round_id'] == old_chal_round_id }

        selected_submissions.each do |sub|
          next if sub["participant_id"].nil?
          old_participant_id = sub["participant_id"]
          sub.delete("id")
          sub.delete("participant_id")
          sub.delete("grading_message")
          sub["challenge_id"] = loop_challenge.id
          sub["challenge_round_id"] = loop_challenge_round.id


          # Until Round Processing is done, we dont want to
          # queue the leaderboard job, so we set below key = true

          if sub["meta"].is_a? Hash
            sub["meta"]["private_ignore-leaderboard-job-computation"] = true
            sub["meta"].delete("repo_url")
          else
            sub["meta"] = {"private_ignore-leaderboard-job-computation": true}
          end

          loop_submission = Submission.create!(sub)

          MigrationMapping.create!(
              source_type: 'Submission',
              source_id: loop_submission.id,
              crowdai_participant_id: old_participant_id
          )
        end
        # Round Processing done, lets queue the leaderboard job
        CalculateLeaderboardJob.perform_later(challenge_round_id: loop_challenge_round.id)
      end
    end
  end
end

puts $list_of_failed_files
# Turn on logger
#ActiveRecord::Base.logger = old_logger
