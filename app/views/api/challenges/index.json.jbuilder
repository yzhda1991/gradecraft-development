json.data @challenges do |challenge|
  next unless !current_student.present? || ChallengeProctor.new(challenge).viewable?(current_student.team_for_course(current_course))
  json.type "challenges"
  json.id challenge.id.to_s
  json.attributes do

    json.description    challenge.description
    json.due_at         challenge.due_at
    json.full_points    challenge.full_points
    json.id             challenge.id
    json.name           challenge.name
    json.visible        challenge.visible

    # boolean states for icons
    json.has_info !challenge.description.blank?
    json.has_levels challenge.challenge_score_levels.present?
    json.is_due_in_future challenge.due_at.present? && challenge.due_at >= Time.now

    json.score_levels challenge.challenge_score_levels.map {
      |csl| {name: csl.name, points: csl.points}
    }
  end

  json.relationships do
    if @predicted_earned_challenges.present? && @predicted_earned_challenges.where(challenge_id: challenge.id).present?
      json.prediction data: {
        type: "predicted_earned_challenges",
        id: @predicted_earned_challenges.where(challenge_id: challenge.id).first.id.to_s
      }
    end

    if @grades.present? && @grades.where(challenge_id: challenge.id).present?
      grade =  @grades.where(challenge_id: challenge.id).first
      if ChallengeGradeProctor.new(grade).viewable?
        json.grade data: { type: "challenge_grades", id: grade.id.to_s }
      end
    end
  end
end

json.included do
  if @predicted_earned_challenges.present?
    json.array! @predicted_earned_challenges do |predicted_earned_challenge|
      json.type "predicted_earned_challenges"
      json.id predicted_earned_challenge.id.to_s
      json.attributes do
        json.id predicted_earned_challenge.id
        json.predicted_points predicted_earned_challenge.predicted_points
      end
    end
  end

  if @grades.present?
    json.array! @grades do |grade|
      next unless ChallengeGradeProctor.new(grade).viewable?
      json.type "challenge_grades"
      json.id grade.id.to_s
      json.attributes do
        json.id             grade.id
        json.score          grade.score
        # final_points should be managed on ChallengeGrades model
        json.final_points   grade.score
      end
    end
  end
end

json.meta do
  json.term_for_challenges term_for :challenges
  json.add_team_score_to_student current_course.add_team_score_to_student
  json.allow_updates @allow_updates
end
