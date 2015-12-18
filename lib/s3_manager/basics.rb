module S3Manager
  module Basics
    def s3_client
      @s3_client ||= Aws::S3::Client.new({
        region: ENV['AWS_S3_REGION'],
        access_key_id: ENV['AWS_ACCESS_KEY_ID'],
        secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
      })
    end

    def s3_resource
      @s3_resource ||= Aws::S3::Resource.new
    end

    def s3_bucket
      s3_client
      @s3_bucket ||= s3_resource.bucket(s3_bucket_name)
    end

    def s3_bucket_name
      @s3_bucket_name ||= "gradecraft-#{Rails.env}"
    end

    def s3_object_attrs
      {
        bucket: s3_bucket_name
      }
    end
  end
end
