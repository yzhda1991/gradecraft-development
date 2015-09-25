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
