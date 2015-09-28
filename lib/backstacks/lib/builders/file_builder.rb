class FileBuilder
  # not representative of the file itself, but is responsible for building the actual file

  # { name: String, files: Array of Hashes, directories: Array of Hashes }
  def initialize(file_attrs={})
    @content_type= file_attrs[:content_type] || "untitled_file"
    @remote_url = file_attrs[:remote_url] || nil
  end

  def create_in_directory(path)
    FileUtils.mkdir(path)
  end

  module Fetchers
    def wget
    end
  end
end
