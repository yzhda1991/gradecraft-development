module S3Manager
  module Basics
    def client
      @client ||= Aws::S3::Client.new({
        region: ENV["AWS_S3_REGION"],
        access_key_id: ENV["AWS_ACCESS_KEY_ID"],
        secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"]
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
      ENV["AWS_S3_BUCKET"]
    end

    def object_attrs
      { bucket: bucket_name }
    end

    def delete_object(object_key)
      client.delete_object({
        bucket: bucket_name,
        key: object_key
      })
    end

    def copy_object(copy_source, target_key)
      bucket.object(copy_source).copy_to(bucket.object(target_key))
    end

    def write_s3_object_to_disk(object_key, target_file_path)
      client.get_object({
        response_target: target_file_path,
        bucket: bucket_name,
        key: object_key
      })
    end

    def get_object(object_key)
      client.get_object({
        bucket: bucket_name,
        key: object_key
      })
    end

    def put_object(object_key, file_path)
      put_object_with_client(client, object_key, file_path)
    end
  end
end
