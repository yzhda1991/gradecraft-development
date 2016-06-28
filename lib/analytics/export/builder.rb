# This is the base class for the ExportBuilder classes that will ultimately
# construct our final export files. By separating this logic out into a
# dedicated class, we can create individiual builder classes that arrange our
# Analytics::Export::Model classes however we'd like but without having to
# rebuild the archiving mechanism for each one.
#
module Analytics
  module Export
    class Builder
      attr_accessor :complete

      attr_reader :export_data, :export_classes, :filename, :directory_name,
                  :output_dir, :export_filepath

      def initialize(export_data:, export_classes:, filename: nil, directory_name: nil)
        @export_data = export_data
        @export_classes = export_classes
        @filename = filename || "exported_files.zip"
        @directory_name = directory_name || "exported_files"
      end

      def generate!
        generate_csvs
        build_zip_archive
      end

      def generate_csvs
        # iterate over the classes that we've been given and
        export_classes.each do |export_class|
          export_class.new(export_data).generate_csv export_dir
        end
      end

      def build_zip_archive
        begin
          # generate the actual zip file here
          Archive::Zip.archive(export_filepath, export_dir)
        ensure
          @complete = true

          # return the filepath once we're done generating the archive
          export_filepath
        end
      end

      # We need to build and name a few directories during the course of our
      # export process. These methods handle all of that.
      #
      def export_root_dir
        # create a named directory where we're going to generate the files
        # inside of the tmpdir that we've already generated
        #
        @export_dir ||= FileUtils.mkdir File.join(export_tmpdir, directory_name)
      end

      def final_archive_tmpdir
        # create a place to store our final archive, for now. Let's set the value as
        # an attribute so we can delete it later.
        #
        @final_archive_tmpdir ||= S3fs.mktmpdir
      end

      def export_tmpdir
        # create a working tmpdir for the export
        #
        @export_tmpdir ||= S3fs.mktmpdir
      end

      def final_export_filepath
        # expand the export filename against our temporary directory path
        #
        @final_export_filepath ||= File.join(final_export_tmpdir, filename)
      end

      def remove_tempdirs
        FileUtils.remove_entry_secure export_dir, final_archive_tmpdir
      end
    end
  end
end
