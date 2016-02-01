module Toolkits
  module S3Manager
    module EncryptionToolkit
      def encrypted_client_attributes
        { 
          kms_key_id: s3_manager.kms_key_id,
          kms_client: s3_manager.kms_client,
          client: s3_manager.client
        }
      end
    end
  end
end
