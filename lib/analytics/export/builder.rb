# This is the base class for the ExportBuilder classes that will ultimately
# construct our final export files. By separating this logic out into a
# dedicated class, we can create individiual builder classes that arrange our
# Analytics::Export::Model classes however we'd like but without having to
# rebuild the archiving mechanism for each one.
#
module Analytics
  module Export
    class Builder
      attr_reader :export_data, :export_classes, :filename, :directory_name,
                  :export_tmpdir, :export_root_dir, :final_export_tmpdir,
                  :complete

      def initialize(export_data:, export_classes:, filename: nil, directory_name: nil)
        @export_data = export_data
        @export_classes = export_classes
        @filename = filename || "exported_files.zip"
        @directory_name = directory_name || "exported_files"
      end

      def build_archive!
        make_directories
        generate_csvs
        build_zip_archive
      end

      # make all of the directories that we're going to use for the export
      #
      def make_directories
        @export_tmpdir = S3fs.mktmpdir
        @final_archive_tmpdir = S3fs.mktmpdir
        FileUtils.mkdir export_root_dir
      end

      # iterate over the classes that we've been given and generate them in the
      # root directory of our export. This method is called #generate_csv right
      # now but should be renamed to #generate_file later to give us a more
      # filetype-agnostic approach.
      #
      def generate_csvs
        export_classes.each do |export_class|
          export_class.new(export_data).generate_csv export_root_dir
        end
      end

      # assemble all of the generated files
      def build_zip_archive
        begin
          # generate the actual zip file here
          Archive::Zip.archive final_export_filepath, export_root_dir
        ensure
          # we're not sending the file to the controller anymore, so let's
          # just upload it to s3
          export.upload_file_to_s3 export_filepath

          export.update_attributes last_completed_step: "build_the_export"

          # return the final export path
          final_export_filepath
        end
      end

      def final_export_filepath
        @final_export_filepath ||= File.join final_export_tmpdir, filename
      end

      def export_root_dir
        @export_root_dir ||= File.join export_tmpdir, directory_name
      end

      def remove_tempdirs
        FileUtils.remove_entry_secure export_root_dir, final_export_tmpdir
      end
    end
  end
end
