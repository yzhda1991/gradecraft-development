module Backstacks
  class ArchiveCleaner
    def initialize(attrs={})
      @source_path = attrs[:source_path]
      @destination_name = attrs[:destination_name]
    end
    
    def work
      if final_archive_exists?
        # alias for rm -rf with protections for malicious code
        FileUtils.remove_entry_secure(tmp_archive_path, true) # true denotes force:true
      end
    end

    def tmp_archive_path
      File.expand_path(@source_path)
    end
  end
end
