json.data @students do |student|
  json.type "student"
  json.id student.id

  json.attributes do
    json.first_name student.first_name
    json.last_name student.last_name
    json.full_name student.name

    json.badge_score student.earned_badge_score_for_course(current_course) if current_course.valuable_badges?
    json.total_score student.score_for_course(current_course)
    json.final_grade student.grade_level_for_course(current_course)

    json.scores do
      assignments ||= [] << current_course.assignment_types.ordered.map do |type|
        type.assignments.ordered
      end

      json.array! assignments.flatten do |assignment|
        grade = assignment.grade_for_student(student)

        json.id grade.try(:id)
        json.value grade.try(:final_points)
        json.grade_link grade_path(grade) unless grade.nil?
      end
    end

    # Links for the clickable entries in the table
    json.student_link student_path(student)
  end
end
