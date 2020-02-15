class ParticipantClefTask < ApplicationRecord
  belongs_to :participant, optional: true
  belongs_to :clef_task

  mount_uploader :eua_file, ParticipantEuaUploader
  validates :eua_file, file_size: { less_than: 10.megabytes }

  def registered?
    status_cd === 'registered'
  end
end
