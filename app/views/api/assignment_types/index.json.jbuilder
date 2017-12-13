json.data @assignment_types do |assignment_type|
  json.type "assignment types"
  json.id assignment_type.id.to_s
  json.attributes do
    json.merge!                   assignment_type.attributes
    json.total_points             assignment_type.total_points_for_settings
    json.is_capped                assignment_type.is_capped?
    json.max_points               assignment_type.max_points
    json.count_only_top_grades    assignment_type.count_only_top_grades?
    json.summed_assignment_points assignment_type.summed_assignment_points

    if @student.present?
      json.final_points_for_student assignment_type.final_points_for_student(@student)
      if assignment_type.student_weightable?
        json.student_weight @student.weight_for_assignment_type(assignment_type)
      end
    end
  end
end

json.meta do
  json.term_for_assignment_type term_for :assignment_type
  json.term_for_weights term_for :weights
  json.update_weights @update_weights

  json.total_weights current_course.try(:total_weights)
  json.weights_close_at current_course.try(:weights_close_at)
  json.max_weights_per_assignment_type current_course.max_weights_per_assignment_type
  json.max_assignment_types_weighted current_course.max_assignment_types_weighted
end
