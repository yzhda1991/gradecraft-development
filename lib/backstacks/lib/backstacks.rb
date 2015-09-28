require "backstacks/version"
require "builders/directory_builder"
require "builders/file_builder"

require "json"
require 'fileutils'
require "open-uri"

# steps:
# 1) parse everything into an array of objects that represent the hashes
# 2) take that array of objects and generate directories for everything
# 3) wget/fetch/curl the files for all of the created temp directories
#   -- > return some kind of error if certain files weren't created properly
# 4) begin compression for the larger directory
#   -- > return some kind of message saying that compression has started

# usage
# archiver = Backstacks::Archive.new(archive_hash).archive_with_compression

archive = Backstacks::Archive.new(json: archive_json, name: archive_name)
archive.objectify_files_and_dirs
archive.assemble_directories_on_disk
archive.create_and_queue_file_jobs

module Backstacks
  class Archive
    def initialize(options={})
      @archive_json = options[:archive_json] || {}
      @archive_name = options[:archive_name] || "untitled_archive"
      @tmp_dir_path = Dir.mktmpdir # need to create a tmp directory for everythign to live in
      @current_directory = @tmp_dir_path
      @file_queue = Resque.new
    end

    def objectify_files_and_dirs
      @archive_objects = ObjectBuilder.new(json: @archive_json).objectify
    end

    def assemble_directories_on_disk
      DirectoryBuilder.new(archive_objects: @archive_objects, base_path: @tmp_dir_path).assemble_recursive
    end

    def populate_files_with_queue
      @file_builder = FileBuilder.new
    end

    def archive_with_compression
    end

    def archive_without_compression
      assemble_recursive
    end
  end
end
