class AssignmentsController < ApplicationController
  include AssignmentsHelper
  include SortsPosition

  before_filter :ensure_staff?, except: [:show, :index, :predictor_data]

  def index
    redirect_to syllabus_path and return if current_user_is_student?
    @title = "#{term_for :assignments}"
    @assignment_types = current_course.assignment_types.includes(:assignments)
  end

  #Gives the instructor the chance to quickly check all assignment settings for the whole course
  def settings
    @title = "Review #{term_for :assignment} Settings"
    @assignment_types = current_course.assignment_types.includes(:assignments)
  end

  def show
    assignment = current_course.assignments.find_by(id: params[:id])
    redirect_to assignments_path,
      alert: "The #{(term_for :assignment)} could not be found." and return unless assignment.present?

    mark_assignment_reviewed! assignment, current_user
    render :show, AssignmentPresenter.build({ assignment: assignment, course: current_course,
                                                team_id: params[:team_id], view_context: view_context })
  end

  def new
    render :new, AssignmentPresenter.build({ assignment: current_course.assignments.new,
                                             course: current_course,
                                             view_context: view_context })
  end

  def edit
    assignment = current_course.assignments.find(params[:id])
    @title = "Editing #{assignment.name}"
    render :edit, AssignmentPresenter.build({ assignment: assignment,
                                              course: current_course,
                                              view_context: view_context })
  end

  # Duplicate an assignment - important for super repetitive items like attendance and reading reactions
  def copy
    assignment = current_course.assignments.find(params[:id])
    duplicated = assignment.copy
    redirect_to assignment_path(duplicated), notice: "#{(term_for :assignment).titleize} #{duplicated.name} successfully created"
  end

  def create
    assignment = current_course.assignments.new(params[:assignment])
    if assignment.save
      set_assignment_weights(assignment)
      redirect_to assignment_path(assignment), notice: "#{(term_for :assignment).titleize} #{assignment.name} successfully created" and return
    end

    @title = "Create a New #{term_for :assignment}"
    render :new, AssignmentPresenter.build({assignment: assignment, course: current_course, view_context: view_context })
  end

  def update
    assignment = current_course.assignments.find(params[:id])
    if assignment.update_attributes(params[:assignment])
      set_assignment_weights(assignment)
      redirect_to assignments_path, notice: "#{(term_for :assignment).titleize} #{assignment.name } successfully updated" and return
    end

    @title = "Edit #{term_for :assignment}"
    render :edit, AssignmentPresenter.build({assignment: assignment, course: current_course, view_context: view_context })
  end

  def sort
    sort_position_for :assignment
  end

  def update_rubrics
    assignment = current_course.assignments.find params[:id]
    assignment.update_attributes use_rubric: params[:use_rubric]
    redirect_to assignment_path(assignment)
  end

  def rubric_grades_review
    assignment = current_course.assignments.find(params[:id])
    render :rubric_grades_review, AssignmentPresenter.build({ assignment: assignment, course: current_course,
                                                              team_id: params[:team_id], view_context: view_context })
  end

  # current student visible assignment
  def predictor_data
    if current_user_is_student?
      student = current_student
    elsif params[:id]
      student = User.find(params[:id])
    else
      student = NullStudent.new(current_course)
    end
    @assignments = PredictedAssignmentCollectionSerializer.new current_course.assignments, current_user, student
  end

  def destroy
    assignment = current_course.assignments.find(params[:id])
    assignment.destroy
    redirect_to assignments_url, notice: "#{(term_for :assignment).titleize} #{assignment.name} successfully deleted"
  end

  def download_current_grades
    assignment = current_course.assignments.find(params[:id])
    respond_to do |format|
      format.csv { send_data GradeExporter.new.export(assignment, current_course.students) }
    end
  end

  def export_grades
    assignment = current_course.assignments.find(params[:id])
    respond_to do |format|
      format.csv { send_data AssignmentExporter.new.export_grades assignment, assignment.course.students }
    end
  end

  def export_submissions
    @assignment = current_course.assignments.find(params[:id])

    if params[:team_id].present?
      team = current_course.teams.find_by(id: params[:team_id])
      zip_name = "#{@assignment.name.gsub(/\W+/, "_").downcase[0..20]}_#{team.name}"
      @students = current_course.students_being_graded_by_team(team)
    else
      zip_name = "#{@assignment.name.gsub(/\W+/, "_").downcase[0..20]}"
      @students = current_course.students_being_graded
    end

    respond_to do |format|
      format.zip do

        export_dir = Dir.mktmpdir
        export_zip zip_name, export_dir do

          require 'open-uri'
          error_log = ""

          open( "#{export_dir}/_grade_import_template.csv",'w' ) do |f|
            f.puts GradeExporter.new.export(@assignment, @students)
          end

          @students.each do |student|
            if submission = student.submission_for_assignment(@assignment)
              if submission.has_multiple_components?
                student_dir = File.join(export_dir, "#{student.last_name}_#{student.first_name}")
                Dir.mkdir(student_dir)
              else
                student_dir = export_dir
              end

              if submission.text_comment.present? or submission.link.present?
                open(File.join(student_dir, "#{student.last_name}_#{student.first_name}_#{@assignment.name.gsub(/\W+/, "_").downcase[0..20]}_submission_text.txt"),'w' ) do |f|
                  f.puts "Submission items from #{student.last_name}, #{student.first_name}\n"
                  f.puts "\ntext comment: #{submission.text_comment}\n" if submission.text_comment.present?
                  f.puts "\nlink: #{submission.link }\n" if submission.link.present?
                end
              end

              if submission.submission_files
                submission.submission_files.each_with_index do |submission_file, i|

                  if Rails.env.development?
                    FileUtils.cp File.join(Rails.root,'public',submission_file.url), File.join(student_dir, "#{student.last_name}_#{student.first_name}_#{@assignment.name.gsub(/\W+/, "_").downcase[0..20]}-#{i + 1}#{File.extname(submission_file.filename)}")
                  else
                    begin
                      destination_file = File.join(student_dir, "#{student.last_name}_#{student.first_name}_#{@assignment.name.gsub(/\W+/, "_").downcase[0..20]}-#{i + 1}#{File.extname(submission_file.filename)}")
                      open(destination_file,'w' ) do |f|
                        f.binmode
                        stringIO = open(submission_file.url)
                        f.write stringIO.read
                      end
                    rescue OpenURI::HTTPError => e
                      error_log += "\nInvalid link for file. Student: #{student.last_name}, #{student.first_name}, submission_file-#{submission_file.id}: #{submission_file.filename}, error: #{e}\n"
                      FileUtils.remove_entry destination_file if File.exist? destination_file
                    rescue Exception => e
                      error_log += "\nError on file. Student: #{student.last_name}, #{student.first_name}, submission_file#{submission_file.id}: #{submission_file.filename}, error: #{e}\n"
                      FileUtils.remove_entry destination_file if File.exist? destination_file
                    end
                  end
                end
              end
            end
          end

          if ! error_log.empty?
            open( "#{export_dir}/_error_Log.txt",'w' ) do |f|
              f.puts "Some errors occurred on download:\n"
              f.puts error_log
            end
          end
        end
      end # format.zip
    end
  end

  private

  def set_assignment_weights(assignment)
    return unless assignment.student_weightable?
    assignment.weights = current_course.students.map do |student|
      assignment_weight = assignment.weights.where(student: student).first || assignment.weights.new(student: student)
      assignment_weight.weight = assignment.assignment_type.weight_for_student(student)
      assignment_weight
    end
    assignment.save
  end
end
