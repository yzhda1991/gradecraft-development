class AssignmentExportPresenter < Presenter::Base
  def submissions_grouped_by_student
    @submissions_grouped_by_student ||= properties[:submissions].group_by do |submission|
      student = submission.student
      "#{student.last_name}_#{student.first_name}-#{student.id}".downcase
    end
  end

  def top_level_files # need specs
    [
      { path: "/assignments/#{@assignment.id}/export_grades.csv", content_type: "text/csv" }
    ]
  end

  def sorted_student_directory_keys
    submissions_grouped_by_student.keys.sort
  end

  def archive_name #needs specs
    "#{properties.assignment.name}"
  end
end

    files = []
    sbs[1].each do |submission|
      if submission.text_comment.present? or submission.link.present?
        student = submission.student
        filename = "#{student.last_name}_#{student.first_name}_#{@assignment.name.gsub(/\W+/, "_").downcase[0..20]}_submission_text.txt"
        contents = "Submission items from #{student.last_name}, #{student.first_name}\n"
        contents += "\ntext comment: #{submission.text_comment}\n" if submission.text_comment.present?
        contents += "\nlink: #{submission.link }\n" if submission.link.present?
        files << { content: contents, name: filename, content_type: "text" }
      end
      if submission.submission_files
        submission.submission_files.each do |sf|
          files << { path: sf.url, content_type: sf.content_type }
        end
      end
    end

  end
end
