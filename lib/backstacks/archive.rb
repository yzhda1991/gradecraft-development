module Backstacks
  class Archive
    def initialize(options={})
      @archive_json = options[:archive_json] || []
      @archive_name = options[:archive_name] || "untitled_archive"
      @archive_type = options[:archive_type] || :zip # :zip or :tar

      # Limit the transfer to a maximum of RATE bytes per second, pulled right from the unix 'pv' utility
      # A suffix of "k", "m", "g", or "t" can be added to denote kilobytes (*1024), megabytes, and so on.
      @rate_limit = options[:rate_limit] || "1m" # default to one megabyte

      @logger = Rails.logger

      @base_path = Dir.mktmpdir # need to create a tmp directory for everythign to live in
      @queue_name = options[:queue_name] || :backstacks_archive
    end

    def build_recursive_on_disk
      @archive_json.each do |directory_json|
        Directory.new(
          directory_hash: directory_json,
          base_path: @base_path,
          queue_name: :backstacks_archive,
          logger: @logger
        ).build_recursive
      end
    end

    def archive_with_compression
      @archive_builder_job = ArchiveBuilder.new(
        source_path: expanded_base_path,
        destination_name: @archive_name,
        archive_type: @archive_type,
        rate_limit: @rate_limit,
        queue_name: @queue_name,
        logger: @logger
      )
      Resque.enqueue(@archive_with_compression)
    end

    def clean_tmp_dir_on_complete
      @archive_cleaner_job = ArchiveCleaner.new(
        source_path: expanded_base_path,
        destination_name: @archive_name,
        queue_name: @queue_name
      )
      Resque.enqueue(@archive_cleaner_job)
    end

    def expanded_base_path
      File.expand_path(@base_path)
    end

    def destination_archive_path
      # some S3 path
    end
  end
end
