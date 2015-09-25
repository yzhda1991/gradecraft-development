require "smart_archiver/version"
require "json"
require 'fileutils'

## Example JSON:
# 
#   { name: "export-directory-name",
#     files: [
#       { remote_url: "http://gradecraft.com/grades/8/grade_import_template.csv", content_type: "text/csv" }
#     ],
#     directories: [
#       { name: "page_jimmy-45",
#         files: [],
#         directories: [
#           { name: "submission_2015-04-10--10:30:54",
#             files: [
#               { remote_url: "https://gradecraft.aws.com/jgashdghf", content_type: "application/pdf" },
#               { remote_url: "https://gradecraft.aws.com/hdsgfhsdfhdsfdksfk", content_type: "application/pdf" },
#               { content: "Lorem Ipsum.....", filename: "jimmy_page_submission.txt", content_type: "text" }
#             ],
#             directories: []
#           }
#         ]
#       }
#     ]
#   }
# 

# start at the top level directory
directory = Directory.new(directory_hash)
directory.assemble_files # create background processes for getting and building individual files
directory.create_sub_directories

class SmartArchiver
  def initialize(options={})
    @json = options[:json] || {}
    @archive_name = options[:archive_name] || "untitled_archive"
  end

  def assemble_recursive
    Directory.create(@json).rescursive_assemble_on_disk
  end

  def generate_compressed_archive
  end
end

class Directory
  # { name: String, files: Array of Hashes, directories: Array of Hashes }
  def initialize(directory_attrs={})
    @name = directory_attrs[:name] || "untitled_directory"
    @files = directory_attrs[:files] || []
    @directories = directory_attrs[:directories] || []
  end

  def create_files
    @files.each do |file_attrs|
      File.new(file_attrs).create_in_directory(self.path)
    end
  end

  def create_sub_directories
    @directories.each do |directory_attrs|
      Directory.new(directory_attrs).create_in_directory(self.path)
    end
  end

  def create_in_directory(path)
    FileUtils.mkdir(path)
  end

  def path
    parent_directories.collect {|d| "/#{d}" }.join
  end

  def parent_directories
    # some enumeration of parent directories
  end
end

class File
  # { name: String, files: Array of Hashes, directories: Array of Hashes }
  def initialize(file_attrs={})
    @content_type= file_attrs[:content_type] || "untitled_file"
    @remote_url = file_attrs[:remote_url] || nil
  end

  def create_in_directory(path)
    FileUtils.mkdir(path)
  end
end

top_level_directory.each do |key, value|
  directory_name = key
  FileUtils.mkdir TEMP_FILES_PATH + directory_name
  directory_contents = value

  if directory_contents["files"]
    directory_contents["files"].each do |file_hash|
      sub_directory
    end
  end

  if directory_contents["directories"]
    directory_contents["directories"].each do |sub_directory_hash|
      sub_directory
    end
  end
end

module SmartArchiver
  module Managers
    class Importer
      def initialize(request_json)
        @request_json = request_json
        @top_level_directory = SmartArchiver::Directory.new(request_json)
        parse_request_json
      end

      private

      def parse_request_json
      
      end
    end

    class Exporter
      def response_json
       { message: response_message, code: response_code }
      end

      private

      def response_message
      end

      def response_code
      end
    end
  end

  class Directory
    def initialize(attrs={})
      @attrs = attrs
      @archive_name = attrs.keys.first
      @files = attrs[:files]
    end
  end

  module Parser
    class File
      def initialize(file_hashes)
        @file_hashes = file_hashes
      end
      attr_reader :file_hashes
    end

    class Directory
      def initialize(directory_hash)
        @directory_hash = directory_hash
        @directory_name = directory_hash.keys.first
      end
      attr_reader :directory_hashes
    end
  end

  class File
    def initialize(attrs={})
      @path = attrs[:path]
      @content_type= attrs[:content_type]
    end
    attr_reader :path, :content_type
  end

  module Compression
  end
end

