class CreateDisentanglementLeaderboards < ActiveRecord::Migration[5.2]
  def change
    create_table :disentanglement_leaderboards do |t|
      t.bigint "challenge_id"
      t.bigint "challenge_round_id"
      t.bigint "participant_id"
      t.integer "row_num"
      t.integer "previous_row_num"
      t.string "slug"
      t.string "name"
      t.integer "entries"
      t.float "score"
      t.float "score_secondary"
      t.string "media_large"
      t.string "media_thumbnail"
      t.string "media_content_type"
      t.string "description"
      t.string "description_markdown"
      t.string "leaderboard_type_cd"
      t.datetime "refreshed_at"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.integer "submission_id"
      t.boolean "post_challenge", default: false
      t.integer "seq"
      t.boolean "baseline"
      t.string "baseline_comment"
      t.json "meta"
      t.float "extra_score1"
      t.float "extra_score2"
      t.float "extra_score3"
      t.float "extra_score4"
      t.float "extra_score5"
      t.float "avg_rank"
      t.index ["challenge_id"], name: "index_disentanglement_leaderboards_on_challenge_id"
      t.index ["challenge_round_id"], name: "index_disentanglement_leaderboards_on_challenge_round_id"
      t.index ["leaderboard_type_cd"], name: "index_disentanglement_leaderboards_on_leaderboard_type_cd"
      t.index ["participant_id"], name: "index_disentanglement_leaderboards_on_participant_id"
    end
  end
end
