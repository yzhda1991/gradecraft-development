class SubmissionFilesExporter
  def initialize(submission)
    @files = []
    @submission = submission
    @assignment = submission.assignment
    @student = submission.student
  end

  def directory_files
    @files << serialized_text_file if has_comment_or_link?
    @files += serialized_submission_files if submission.submission_files.present?
    @files
  end

  attr_reader :files, :submission, :student, :assignment

  private 

  def formatted_text_filename
    base_text_filename.downcase.gsub(/_+/,"_")
  end

  def base_text_filename
    "#{student.last_name}_#{student.first_name}_#{assignment_name_snippet}_submission_content.txt"
  end

  def assignment_name_snippet
    assignment.name.gsub(/\W+/, "_").slice(0..20)
  end

  def serialized_submission_files
    submission.submission_files.collect do |submission_file|
      { path: submission_file.url, content_type: submission_file.content_type }
    end
  end

  def serialized_text_file
    { content: text_file_content, filename: formatted_text_filename, content_type: "text" }
  end

  def text_file_content
    [ text_content_title, text_comment, submission_link ].compact.join("\n")
  end

  # text file methods
  def text_content_title
    "Submission items from #{student.last_name}, #{student.first_name}\n"
  end

  def text_comment
    "\ntext comment: #{submission.text_comment}\n" if submission.text_comment.present?
  end

  def submission_link
    "\nlink: #{submission.link }\n" if submission.link.present?
  end

  def has_comment_or_link?
    submission.text_comment.present? or submission.link.present?
  end
end
