module Backstacks
  class DirectoryBuilder
    # { name: String, files: Array of Hashes, directories: Array of Hashes }
    def initialize(directory_attrs={})
      @name_attr = directory_attrs[:name] || "untitled_directory"
      @archive_json = directory_attrs[:archive_json] || []
      @base_path = directory_attrs[:base_path] || Rails.root + "/tmp"
    end
    
    def archive_json(directories_json)
    end


    def set_base_path(path)
      @base_path = path
    end

    def create_sub_directories
      @sub_directories = @directory_attrs.collect do |sub_dir_attrs|
        Directory.new(sub_dir_attrs).create_in_directory(self.path)
      end
    end

    def assemble_recursive
      mkdir_current_directory(@base_path)
      create_sub_directories
    end

    def mkdir_current_directory(path)
      FileUtils.mkdir(path)
    end
  end
end
