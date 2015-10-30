module SmartArchiver
  class Builder

    def initialize(attrs={})
      @source_path = attrs[:source_path]
      @destination_name = attrs[:destination_name]
      @archive_type = attrs[:archive_type]
      @rate_limit = attrs[:rate_limit]
    end
    
    def final_archive_exists?
      File.file? final_archive_path
    end

    def final_archive_path
      File.expand_path(final_archive_dir, @destination_name)
    end

    def start_archiver!
      case @archive_type
      when :zip
        `zip -r - #{@source_path} | pv -L #{@rate_limit} >#{@destination_name}.zip`
      when :tar
        `tar czvf - #{@source_path} | pv -L #{@rate_limit} >#{@destination_name}.tgz`
      end
    end
  end
end
