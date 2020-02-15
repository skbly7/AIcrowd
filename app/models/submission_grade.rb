class SubmissionGrade < ApplicationRecord
  belongs_to :submission
  after_save :update_submission
  default_scope { order('created_at DESC') }

  as_enum :grading_status, [:ready, :submitted, :graded, :failed, :initiated], map: :string, accessor: :whiny

  validates :submission_id, presence: true
  validates :grading_status, presence: true

  def update_submission
    Submission.update(
      submission_id,
      grading_status:  grading_status,
      grading_message: grading_message,
      score:           score,
      score_secondary: score_secondary)
  end
end
