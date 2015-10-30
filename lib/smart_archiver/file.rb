module SmartArchiver
  class File

    def initialize(attrs={}, current_directory, queue_name)
      @path = attrs[:path]
      @content_type = attrs[:content_type]
    end

    def get
      `wget #{@path} #{current_directory}`
    end
  end
end
