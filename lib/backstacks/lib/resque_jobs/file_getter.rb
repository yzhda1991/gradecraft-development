module Backstacks
  class FileGetter
    def initialize(attrs={}, current_directory, queue_name)
      @path = attrs[:path]
      @content_type = attrs[:content_type]
      @queue = queue_name
    end

    def perform 
      `wget #{@path} #{current_directory}`
    end
  end
end
