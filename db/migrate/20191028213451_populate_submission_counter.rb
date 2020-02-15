class PopulateSubmissionCounter < ActiveRecord::Migration[5.2]
  def up
    Challenge.find_each do |challenge|
      Challenge.reset_counters(challenge.id, :submissions)
    end
  end
end
