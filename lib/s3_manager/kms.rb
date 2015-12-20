module S3Manager
  module Kms
    def kms_client
      @kms_client ||= Aws::KMS::Client.new
    end

    def kms_key_id
      @kms_key_id ||= ENV['AWS_KMS_KEY_ID']
    end
  end
end
