require "backstacks/version"
require_relative "directory"

require_relative "resque_jobs/archive_builder"
require_relative "resque_jobs/archive_cleaner"
require_relative "resque_jobs/file_getter"

require 'json'
require 'fileutils'
require 'open-uri'
require 'resque'

# steps:
# 1) parse everything into an array of objects that represent the hashes
# 2) take that array of objects and generate directories for everything
# 3) wget/fetch/curl the files for all of the created temp directories
#   -- > return some kind of error if certain files weren't created properly
# 4) begin compression for the larger directory
#   -- > return some kind of message saying that compression has started

# usage

# archive = Backstacks::Archive.new(json: archive_json, name: archive_name, max_cpu_usage: 0.2)
# archive.assemble_directories_on_disk
# compression_job = archive.archive_with_compression
# if compression_job.finished>
# archive.remove_tmp_files

module Backstacks
  class Archive
    def initialize(options={})
      @archive_json = options[:archive_json] || []
      @archive_name = options[:archive_name] || "untitled_archive"
      @max_cpu_usage = options[:max_cpu_usage] || 0.3
      @base_path = Dir.mktmpdir # need to create a tmp directory for everythign to live in
      @queue_name = options[:queue_name] || :backstacks_archive
    end

    def build_recursive_on_disk
      @archive_json.each do |directory_json|
        Directory.new(
          directory_hash: directory_json,
          base_path: @base_path,
          queue_name: :backstacks_archive
        ).build_recursive
      end
    end

    def archive_with_compression
      @archive_builder_job = ArchiveBuilder.new(
        source_path: expanded_base_path,
        destination_name: @archive_name,
        queue_name: @queue_name
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
    end
  end
end
