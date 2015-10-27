require "backstacks/version"
require_relative "directory"

require_relative "resque_jobs/archive_builder"
require_relative "resque_jobs/archive_cleaner"
require_relative "resque_jobs/file_getter"

require 'json'
require 'fileutils'
require 'open-uri'
require 'resque'
require 'resque/errors'

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
