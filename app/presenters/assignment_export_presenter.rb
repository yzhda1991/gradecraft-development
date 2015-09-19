class AssignmentExportPresenter < Presenter::Base
  def submissions_by_student
    properties[:submissions_for_export].group_by do |submission|
      student = submission[:student]
      "#{student[:last_name]}_#{student[:first_name]}-#{student[:id]}".downcase
    end
  end
end
