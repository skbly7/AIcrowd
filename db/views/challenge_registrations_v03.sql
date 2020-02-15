SELECT row_number() OVER () AS id,
       challenge_id,
       participant_id,
       registration_type,
       clef_task_id
FROM   (SELECT s.challenge_id,
               s.participant_id,
               'submission' AS "registration_type",
               NULL::INTEGER AS clef_task_id
        FROM   submissions s
        UNION
        SELECT s.votable_id,
               s.participant_id,
               'heart' AS "registration_type",
               NULL::INTEGER AS clef_task_id
        FROM   votes s
        WHERE  s.votable_type = 'Challenge'
        UNION
        SELECT df.challenge_id,
               dfd.participant_id,
               'dataset_download',
               NULL::INTEGER AS clef_task_id
        FROM   dataset_file_downloads dfd,
               dataset_files df
        WHERE  dfd.dataset_file_id = df.id
        UNION
        SELECT c.id,
               pc.participant_id,
               'clef_task' AS "registration_type",
               pc.clef_task_id
        FROM   participant_clef_tasks pc,
               challenges c
        WHERE c.clef_task_id = pc.clef_task_id) x
