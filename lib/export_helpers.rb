# @mz todo: add specs
module ExportAddons
  module S3
    def s3_object_key
      "#{s3_object_key_path}/#{export_filename}"
    end

    def s3_object_key_path
      "/exports"
    end

    def s3_object
      @s3_object ||= s3_bucket.object(s3_object_key)
    end

    def s3_object_key
      "#{s3_object_key_path}/#{export_filename}"
    end
  end
end
