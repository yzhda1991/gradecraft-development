class AssignmentExport < Export
  belongs_to :course
  belongs_to :professor, class_name: "User", foreign_key: "professor_id"
  belongs_to :team
  belongs_to :assignment

  attr_accessible :course_id, :professor_id, :team_id, :assignment_id, :submissions_snapshot

  def s3_object_key_path
    "/exports/courses/#{course_id}/assignments/#{assignment_id}/"
  end

end
