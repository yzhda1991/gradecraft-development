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

    def put_encrypted_object(object_key, body)
      encrypted_client.put_object({
        bucket: bucket_name,
        server_side_encryption: "AES256",
        key: object_key,
        body: body
      })
    end

    def get_encrypted_object(object_key)
      encrypted_client.get_object({
        bucket: bucket_name,
        key: object_key
      })
    end
  end
end
