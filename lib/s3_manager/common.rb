module S3Manager
  module Common
    def put_object_with_client(target_client, object_key, file_path)
      File.open(file_path, 'rb') do |streamed_file|
        target_client.put_object({
          bucket: bucket_name,
          server_side_encryption: "AES256",
          key: object_key,
          body: streamed_file
        })
      end
    end
  end
end
