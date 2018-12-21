class PermanentRating < ApplicationRecord
	belongs_to :participant
	belongs_to :challenge, optional: true
end
