module Backstacks
  class Directory
    def initialize(attrs={})
      @directory_hash = attrs[:directory_hash]
      @base_path = attrs[:base_path]
      @queue_name = attrs[:queue_name]
      @current_directory = File.expand_path(@base_path, "/#{@directory_hash[:directory_name]}")
    end

    def build_recursive
      create_current_directory unless directory_exists?(@current_directory)
      create_files
      create_sub_directories
    end

    def create_files
      # check if the current directory hash has files
      if @directory_hash[:files].present?
        # add file getter jobs for files in the directory
        @directory_hash[:files].each do |file_hash|
          @file_getter = FileGetter.new(file_hash, @current_directory, @queue_name)
          Resque.enqueue(@file_getter)
        end
      end
    end

    def create_sub_directories
      # check if the current directory has has sub-directories
      if @directory_hash[:sub_directories].present?
        @directory_hash[:sub_directories].each do |sub_directory_hash|
          Directory.new(
            directory_hash: sub_directory_hash,
            base_path: current_directory,
            file_queue: @file_queue
          ).build_recursive
        end
      end
    end

    protected
    def create_current_directory
      FileUtils.mkdir(@current_directory)
    end

    def directory_exists?(path)
      Dir.exists?(path)
    end
  end
end
