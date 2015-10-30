# SmartArchiver

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/smart_archiver`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'smart_archiver'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install smart_archiver

## Usage

### Example Jbuilder:
 
```
json.directory_name @presenter.export_file_name
json.files do [{ path: @presenter.csv_file_path, content_type: "text/csv" }]

json.sub_directories do
  @submissions_by_student.each do |student_with_submissions|
    json.directory_name student_with_submissions.first do # this is the "page_jimmy-45" key
    json.sub_directories do
      student_with_submissions.last.each do |submission| # an array of submissions for the student
        json.files SubmissionFilesExporter.new(submission).directory_files
      end
    end
  end
end
```

### Example JSON:
```
[
  {
    directory_name: "export directory name",
    files: [
      { path: "http://gradecraft.com/grades/8/grade_import_template.csv", content_type: "text/csv" }
    ],
    sub_directories: [

      {
        directory_name: "page_jimmy-45",
        sub_directories: [

          {
            directory_name: "submission_2015-04-10--10:30:54",
            files: [
              { path: "https://gradecraft.aws.com/jgashdghf", content_type: "application/pdf" },
              { path: "https://gradecraft.aws.com/hdsgfhsdfhdsfdksfk", content_type: "application/pdf" },
              { content: "Lorem Ipsum.....", filename: "jimmy_page_submission.txt", content_type: "text" }
            ]
          }
        ]
      }
    ]
  }
]
```

```
# start at the top level directory
@archive = SmartArchiver::Archive.new(json: archive_json, name: archive_name, max_cpu_usage: 0.2)
@archive.assemble_directories_on_disk # build the directory structure and create file-getting jobs
@archive.archive_with_compression # create tar job for directory
@archive.clean_tmp_dir_on_complete # create job for removing the tmp directory on completion

```

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Method that it's replacing

This is the method that the smart archiver is replacing, any functionality here should be represented by the smart archiver library in some way:

```
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
            f.puts @assignment.grade_import(@students)
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
```


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/smart_archiver. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

