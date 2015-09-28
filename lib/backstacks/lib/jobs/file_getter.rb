module Backstacks
  class FileGetter
    def initialize(attrs)
      @path = attrs[:path]
      @content_type = attrs[:content_type]
    end

    def work
      `wget #{@path} #{@current_directory}`
    end
  end
end
