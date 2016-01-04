module S3Manager
  module Encryption
    # requires S3Manager::Kms
    # requires S3Manager::Basic
    def encrypted_client
      @encrypted_client ||= Aws::S3::Encryption::Client.new(
        kms_key_id: kms_key_id,
        kms_client: kms_client,
        client: client
      )
    end

    def put_encrypted_object(object_key, file_path)
      File.open(file_path, 'rb') do |streamed_file|
        encrypted_client.put_object({
          bucket: bucket_name,
          server_side_encryption: "AES256",
          key: object_key,
          body: streamed_file
        })
      end
    end

    def get_encrypted_object(object_key)
      encrypted_client.get_object({
        bucket: bucket_name,
        key: object_key
      })
    end

    def write_encrypted_object_to_file(object_key, local_file_path)
      encrypted_client.get_object({
        response_target: local_file_path,
        bucket: bucket_name,
        key: object_key
      })
    end
  end
end
