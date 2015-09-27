require "backstacks/version"

# managers
require 'mangers/importer'
require 'mangers/exporter'

# parsers
require 'parsers/directory'
require 'parsers/file'

# compressors

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
module Backstacks
  class Archive
    def initialize(options={})
      @archive_json = options[:archive_json] || {}
      @archive_name = options[:archive_name] || "untitled_archive"
      @tmp_dir_path = Dir.mktmpdir # need to create a tmp directory for everythign to live in
    end

    def assemble_recursive
      @top_level_directory = Directory.new(@archive_json)
      @top_level_directory.base_path = @tmp_dir_path
      @top_level_directory.rescursive_assemble_on_disk
    end

    def archive_with_compression
    end

    def archive_without_compression
      assemble_recursive
    end
  end
end
