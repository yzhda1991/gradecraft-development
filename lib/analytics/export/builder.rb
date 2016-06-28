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
                  :export_tmpdir, :export_root_dir, :final_archive_tmpdir,
                  :final_export_filepath, :complete

      def initialize(export_data:, export_classes:, filename: nil, directory_name: nil)
        @export_data = export_data
        @export_classes = export_classes
        @filename = filename || "exported_files.zip"
        @directory_name = directory_name || "exported_files"
      end

      def generate!
        make_directories
        generate_csvs
        build_zip_archive
      end

      def make_directories
        @export_tmpdir = S3fs.mktmpdir
        @export_root_dir = FileUtils.mkdir File.join(export_tmpdir, directory_name)
        @final_archive_tmpdir = S3fs.mktmpdir
      end

      def generate_csvs
        # iterate over the classes that we've been given and
        export_classes.each do |export_class|
          export_class.new(export_data).generate_csv export_root_dir
        end
      end

      def build_zip_archive
        begin
          # generate the actual zip file here
          Archive::Zip.archive final_export_filepath, export_root_dir
        ensure
          @complete = true

          # return the filepath once we're done generating the archive
          final_export_filepath
        end
      end

      def final_export_filepath
        @final_export_filepath ||= File.join final_export_tmpdir, filename
      end

      def remove_tempdirs
        FileUtils.remove_entry_secure export_root_dir, final_archive_tmpdir
      end
    end
  end
end
