# Missing values (New entry)
# Existing entry ()

# Make a full proof plan for calculation

challenges = Challenge.where(status_cd: "running") # Sort in termination order

p_rating = {}
challenges.each do |challenge|
	
	team_to_rank = {}
	leaderboards = Leaderboard.where(challenge_id: challenge.id).pluck([:participant_id, :row_num]).to_h

	leaderboards.keys.each do |participant_id|
		unless p_rating.key?(participant_id)
			p_rating[participant_id] = PermanentRating.where(participant_id: participant_id).empty? ? [Saulabs::TrueSkill::Rating.new(25.0, 8.33)] : [Saulabs::TrueSkill::Rating.new(PermanentRating.where(participant_id: participant_id).last.mean, PermanentRating.where(participant_id: participant_id).last.deviation)] 
		end
		team_to_rank[p_rating[participant_id]] = leaderboards[participant_id].to_i
	end

  graph = Saulabs::TrueSkill::FactorGraph.new team_to_rank
  graph.update_skills
end

TemporaryRating.transaction do
	p_rating.keys.each do |participant_id|
		TemporaryRating.create(participant_id: participant_id, mean: p_rating[participant_id][0].mean, deviation: p_rating[participant_id][0].deviation)
	end
end