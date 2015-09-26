require "smart_archiver/version"

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
# archiver = SmartArchiver::Archive.new(archive_hash).archive_with_compression
module SmartArchiver
  class Archive
    def initialize(options={})
      @json = options[:json] || {}
      @archive_name = options[:archive_name] || "untitled_archive"
      @tmp_dir = Dir.mktmpdir # need to create a tmp directory for everythign to live in
    end

    def assemble_recursive
      Directory.create(@json).rescursive_assemble_on_disk
    end

    def archive_with_compression
    end

    def archive_without_compression
      assemble_recursive
    end
  end
end
