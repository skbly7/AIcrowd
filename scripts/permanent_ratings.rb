challenge = Challenge.friendly.find(30) # Challenge which has ended

p_rating = {}
	
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

PermanentRating.transaction do
	p_rating.keys.each do |participant_id|
		PermanentRating.create(participant_id: participant_id, mean: p_rating[participant_id][0].mean, deviation: p_rating[participant_id][0].deviation,challenge_id: challenge.id)
	end
end