def export_submissions

  # @assignment = current_course.assignments.find(params[:id]) # handled by assignment_exports_controller: fetch_assignment

  # # entire block handled by submissions and submissions_by_team methods, and by 
  # if params[:team_id].present?
  #   team = current_course.teams.find_by(id: params[:team_id])
  #   zip_name = "#{@assignment.name.gsub(/\W+/, "_").downcase[0..20]}_#{team.name}"
  #   @students = current_course.students_being_graded_by_team(team)
  # else
  #   zip_name = "#{@assignment.name.gsub(/\W+/, "_").downcase[0..20]}"
  #   @students = current_course.students_being_graded
  # end

  # respond_to do |format|
    # format.zip do

      # export_dir is the just the temp dir
      export_dir = Dir.mktmpdir
      
      # TODO: actually perform compression
      export_zip zip_name, export_dir do

        require 'open-uri'
        error_log = ""

        # write the CSV for the export
        # save the csv refactor until the grade export is working properly
        open( "#{export_dir}/_grade_import_template.csv",'w' ) do |f|
          f.puts @assignment.grade_import(@students)
        end

        @students.each do |student|
          if submission = student.submission_for_assignment(@assignment)
            if submission.has_multiple_components?
              student_dir = File.join(export_dir, "#{student.last_name}_#{student.first_name}")
              Dir.mkdir(student_dir) # make the directory for the student within the submission
            else
              student_dir = export_dir # set the current export directory to the new student directory
            end

            if submission.text_comment.present? or submission.link.present? # write the text file for the submission into the student export directory
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
