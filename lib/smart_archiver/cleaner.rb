module SmartArchiver
  class Cleaner
    def initialize(attrs={})
      @source_path = attrs[:source_path]
      @destination_name = attrs[:destination_name]
    end
    
    def remove_tmp_files!
      if final_archive_exists?
        # alias for rm -rf with protections for malicious code
        FileUtils.remove_entry_secure(tmp_archive_path, true) # true denotes force:true
      end
    end

    def final_archive_exists?
      File.file?(final_archive_path)
    end

    def final_archive_path
      # need to flesh this out with code for checking whether the .tgz archive was successfuly created
    end

    def tmp_archive_path
      File.expand_path(@source_path)
    end
  end
end
