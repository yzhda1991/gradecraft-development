module Analytics
  class ExportBuilder
    # **** Now that I look at this it's clear that this should really just be an
    # Analytics::Export::Builder class that accepts an array of export classes
    # and a context. This allows us to keep the archive generation process
    # separate from the organization of the export data fetching, and the
    # export organization itself ****
    #
    attr_accessor :complete

    attr_reader :export, :output_dir, :export_filepath

    def initialize(export:)
      @export = export
    end

    def generate!
      generate_csvs
      build_zip_archive
    end

    def export_dir
      # return the export dir if we've already built it
      return @export_dir if @export_dir

      # create a working tmpdir for the export
      export_tmpdir = Dir.mktmpdir nil, s3fs_prefix

      # create a named directory to generate the files in
      @export_dir = FileUtils.mkdir \
        File.join(export_tmpdir, export.directory_name)
    end

    def generate_csvs
      export.export_classes.each do |export_class|
        export_class.new(export.context.export_data).generate_csv export_dir
      end
    end

    def build_zip_archive
      # create a place to store our final archive, for now. Let's set the value as
      # an attribute so we can delete it later.
      #
      @output_dir = Dir.mktmpdir nil, s3fs_prefix

      # expand the export filename against our temporary directory path
      @export_filepath = File.join(output_dir, export.filename)

      begin
        # generate the actual zip file here
        Archive::Zip.archive(@export_filepath, export_dir)
      ensure
        @complete = true

        # return the filepath once we're done generating the archive
        @export_filepath
      end
    end

    def use_s3fs?
      # check whether we need to use S3fs
      %w[staging production].include? Rails.env
    end

    def s3fs_prefix
      # if we do use the prefix for the s3fs tempfiles
      use_s3fs? ? "/s3mnt/tmp/#{Rails.env}" : nil
    end

    def remove_tempdirs
      FileUtils.remove_entry_secure export_dir, output_dir
    end
end
