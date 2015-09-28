module Backstacks
  class ArchiveBuilder
    def initialize(attrs={})
      @source_path = attrs[:source_path]
      @destination_name = attrs[:destination_name]
    end
    
    def work
      `tar czvf - #{@source_path} | pv -L 1m >#{@destination_name}.tgz`
    end

    def final_archive_exists?
      File.file? final_archive_path
    end

    def final_archive_path
      File.expand_path(final_archive_dir, @destination_name)
    end
  end
end
