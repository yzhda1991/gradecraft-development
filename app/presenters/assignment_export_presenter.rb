class AssignmentExportPresenter < Presenter::Base
  def submissions_grouped_by_student
    @submissions_grouped_by_student ||= properties[:submissions].group_by do |submission|
      student = submission.student
      "#{student[:last_name]}_#{student[:first_name]}-#{student[:id]}".downcase
    end
  end

  def sorted_student_directory_keys
    submissions_grouped_by_student.keys.sort
  end
end
