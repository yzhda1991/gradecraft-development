module S3Manager
  module Basics
    def client
      @client ||= Aws::S3::Client.new({
        region: ENV['AWS_S3_REGION'],
        access_key_id: ENV['AWS_ACCESS_KEY_ID'],
        secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
      })
    end

    def resource
      @resource ||= Aws::S3::Resource.new
    end

    def bucket
      client
      @bucket ||= resource.bucket(bucket_name)
    end

    def bucket_name
     "gradecraft-#{Rails.env}"
    end

    def object_attrs
      {
        bucket: bucket_name
      }
    end

    def delete_object(object_key)
      client.delete_object({
        bucket: bucket_name,
        key: object_key
      })
    end
  end
end
