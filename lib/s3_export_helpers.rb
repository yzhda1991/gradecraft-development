# @mz todo: add specs
module ExportHelpers
  module S3
    before_create :set_s3_symmetric_key

    def s3_client
      @s3_client ||= Aws::S3::Client.new
    end

    def s3_bucket
      @s3_bucket ||= s3_client.buckets[s3_bucket_name]
    end

    def s3_bucket_name
      "gradecraft-#{Rails.env}"
    end

    def s3_object_key
      "#{s3_object_key_path}/#{export_filename}"
    end

    def export_filename
      @export_filename ||= random_cipher_key
    end

    def random_cipher_key
      OpenSSL::Cipher.new("AES-256-ECB").random_key
    end

    def s3_object_key_path
      "/exports"
    end

    def set_s3_symmetric_key
      self[:s3_symmetric_key] = random_cipher_key
    end

    def s3_object
      @s3_object ||= s3_bucket.object(s3_object_key)
    end
  end
end

