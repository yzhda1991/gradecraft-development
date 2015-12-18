module S3Manager
  module Encryption
    # requires S3Manager::Kms
    # requires S3Manager::Basic
    def encrypted_s3_client
      @encrypted_s3_client ||= Aws::S3::Encryption::Client.new(
        kms_key_id: kms_key_id,
        kms_client: kms_client,
        client: s3_client
      )
    end

    def get_client_encrypted_object
    end

    def put_client_encrypted_object
    end
  end
end
