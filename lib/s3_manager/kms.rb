module S3Manager
  module Kms
    def kms_client
      @kms_client ||= Aws::KMS::Client.new
    end

    def kms_key_id
      @kms_key_id ||= kms_client.create_key.key_metadata.key_id
    end
  end
end
