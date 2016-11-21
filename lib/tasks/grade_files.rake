namespace :grade_files do

  desc "Add grade file association for many to many relationship"
  task add_associations: :environment do
    GradeFile.find_each(batch_size: 500) do |gf|
      if GradeFileAssociation.where(grade_file_id: gf.id, grade_id: gf.grade_id).empty?
        GradeFileAssociation.create(grade_file_id: gf.id, grade_id: gf.grade_id)
      end
    end
  end
end
