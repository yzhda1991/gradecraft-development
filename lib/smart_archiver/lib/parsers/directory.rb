module SmartArchiver
  module Parsers

    class Directory
      # { name: String, files: Array of Hashes, directories: Array of Hashes }
      def initialize(directory_attrs={})
        @name = directory_attrs[:name] || "untitled_directory"
        @files = directory_attrs[:files] || []
        @directories = directory_attrs[:directories] || []
        @base_path = directory_attrs[:base_path] = Rails.root + "/tmp"
      end

      def create_files
        @files.each do |file_attrs|
          File.new(file_attrs).create_in_directory(self.path)
        end
      end

      def set_base_path(path)
        @base_path = path
      end

      def create_sub_directories
        @directories.each do |directory_attrs|
          Directory.new(directory_attrs).create_in_directory(self.path)
        end
      end

      def recursive_assemble_on_disk
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

  end
end
