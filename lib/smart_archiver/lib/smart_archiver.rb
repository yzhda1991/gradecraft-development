require "smart_archiver/version"
require "json"

module SmartArchiver
  class ImportHash < Hash
    def initialize(attrs={})
      
    end
  end

  class Directory
    def initialize(attrs={})
      @attrs = attrs
      @files = attrs[:files]
    end
  end

  class File
  end

  module Compression
  end
end
