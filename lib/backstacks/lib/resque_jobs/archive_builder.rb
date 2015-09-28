module Backstacks
  class ArchiveBuilder
    def initialize(attrs={})
      @source_path = attrs[:source_path]
      @destination_name = attrs[:destination_name]
    end
    
    def work
      `tar czvf - #{@source_path} | pv -L 1m >#{@destination_name}.tgz`
    end
  end
end
