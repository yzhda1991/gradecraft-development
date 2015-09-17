class AssignmentExportsController < ApplicationController
  before_filter :fetch_assignment
  respond_to :json

  def submissions
    @submissions ||= @assignment.student_submissions
  end

  def submissions_by_team
    @team = Team.find params[:team_id]
    @submissions ||= @assignment.student_submissions_for_team(@team)
  end

  def export
    fetch_assignment
    @submissions ||= @assignment.student_submissions
    group_submissions_by_student
  end

  private

    def group_submissions_by_student
      @submissions_by_student ||= @submissions.group_by do |submission|
        student = submission.student
        "#{student[:last_name]}_#{student[:first_name]}-#{student[:id]}".downcase
      end
    end

    def fetch_assignment
      @assignment ||= Assignment.find params[:assignment_id]
    end

  public

#   def export_submissions
#
#     @assignment = current_course.assignments.find(params[:id])
#
#     if params[:team_id].present?
#       team = current_course.teams.find_by(id: params[:team_id])
#       zip_name = "#{@assignment.name.gsub(/\W+/, "_").downcase[0..20]}_#{team.name}"
#       @students = current_course.students_being_graded_by_team(team)
#     else
#       zip_name = "#{@assignment.name.gsub(/\W+/, "_").downcase[0..20]}"
#       @students = current_course.students_being_graded
#     end
#
#     respond_to do |format|
#       format.zip do
#
#         export_dir = Dir.mktmpdir
#         export_zip zip_name, export_dir do
#
#           require 'open-uri'
#           error_log = ""
#
#           open( "#{export_dir}/_grade_import_template.csv",'w' ) do |f|
#             f.puts @assignment.grade_import(@students)
#           end
#
#           @students.each do |student|
#             if submission = student.submission_for_assignment(@assignment)
#               if submission.has_multiple_components?
#                 student_dir = File.join(export_dir, "#{student.last_name}_#{student.first_name}")
#                 Dir.mkdir(student_dir)
#               else
#                 student_dir = export_dir
#               end
#
#               if submission.text_comment.present? or submission.link.present?
#                 open(File.join(student_dir, "#{student.last_name}_#{student.first_name}_#{@assignment.name.gsub(/\W+/, "_").downcase[0..20]}_submission_text.txt"),'w' ) do |f|
#                   f.puts "Submission items from #{student.last_name}, #{student.first_name}\n"
#                   f.puts "\ntext comment: #{submission.text_comment}\n" if submission.text_comment.present?
#                   f.puts "\nlink: #{submission.link }\n" if submission.link.present?
#                 end
#               end
#
#               if submission.submission_files
#                 submission.submission_files.each_with_index do |submission_file, i|
#
#                   if Rails.env.development?
#                     FileUtils.cp File.join(Rails.root,'public',submission_file.url), File.join(student_dir, "#{student.last_name}_#{student.first_name}_#{@assignment.name.gsub(/\W+/, "_").downcase[0..20]}-#{i + 1}#{File.extname(submission_file.filename)}")
#                   else
#                     begin
#                       destination_file = File.join(student_dir, "#{student.last_name}_#{student.first_name}_#{@assignment.name.gsub(/\W+/, "_").downcase[0..20]}-#{i + 1}#{File.extname(submission_file.filename)}")
#                       open(destination_file,'w' ) do |f|
#                         f.binmode
#                         stringIO = open(submission_file.url)
#                         f.write stringIO.read
#                       end
#                     rescue OpenURI::HTTPError => e
#                       error_log += "\nInvalid link for file. Student: #{student.last_name}, #{student.first_name}, submission_file-#{submission_file.id}: #{submission_file.filename}, error: #{e}\n"
#                       FileUtils.remove_entry destination_file if File.exist? destination_file
#                     rescue Exception => e
#                       error_log += "\nError on file. Student: #{student.last_name}, #{student.first_name}, submission_file#{submission_file.id}: #{submission_file.filename}, error: #{e}\n"
#                       FileUtils.remove_entry destination_file if File.exist? destination_file
#                     end
#                   end
#                 end
#               end
#             end
#           end
#
#           if ! error_log.empty?
#             open( "#{export_dir}/_error_Log.txt",'w' ) do |f|
#               f.puts "Some errors occurred on download:\n"
#               f.puts error_log
#             end
#           end
#         end
#       end # format.zip
#     end
#   end

end
