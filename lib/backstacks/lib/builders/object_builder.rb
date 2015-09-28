module Backstacks
  class ObjectBuilder 
    # { 
    #   directory_name: String,
    #   files: "array of file hashes",
    #   sub_directories: "array of directory hashes"
    # }

    def initialize(archive_json)
      @archive_json = archive_json
    end

    def initialize(directory_attrs={})
    end

    def create_sub_directories
      @sub_directories = @directory_attrs.collect do |sub_dir_attrs|
        Directory.new(sub_dir_attrs).create_in_directory(self.path)
      end
    end

    def assemble_recursive
      create_sub_directories
    end
  end
end
