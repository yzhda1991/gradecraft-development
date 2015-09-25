require "smart_archiver/version"

require 'parsers/directory'
require 'parsers/file'

require "json"
require 'fileutils'

# steps:
# 1) parse everything into an array of objects that represent the hashes
# 2) take that array of objects and generate directories for everything
# 3) wget/fetch/curl the files for all of the created temp directories
#   -- > return some kind of error if certain files weren't created properly
# 4) begin compression for the larger directory
#   -- > return some kind of message saying that compression has started

module SmartArchiver
  def initialize(options={})
    @json = options[:json] || {}
    @archive_name = options[:archive_name] || "untitled_archive"
    @tmp_dir = Dir.mktmpdir # need to create a tmp directory for everythign to live in
  end

  def assemble_recursive
    Directory.create(@json).rescursive_assemble_on_disk
  end

  def generate_compressed_archive
  end
end
