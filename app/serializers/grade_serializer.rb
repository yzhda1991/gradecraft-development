# Student safe attributes only, should only be used on grades for current_user
# TODO: make current scopes available here

class GradeSerializer < ActiveModel::Serializer

  attributes :id, :assignment_id, :assignment_type_id, :point_total,:predicted_score, :status, :late
  has_one :assignment

  # NOTE: grades not yet created are not present!
  def late
    assignment.past?
    && assignment.accepts_submissions
    && ! scope.submission_for_assignment(assignment).present?
    ? true : false
  end

  def attributes
    data = super
    data[:point_total] = status == "Graded" ? point_total : nil
    data
  end
end
