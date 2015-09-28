module Backstacks
  class ObjectBuilder 
    # { name: String, files: Array of Hashes, directories: Array of Hashes }
    def initialize(archive_json)
      @archive_json = archive_json
    end

    def initialize(directory_attrs={})
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
