module Toolkits
  module S3Manager
    module BasicsToolkit
      def s3_client_attributes
        { 
          region: ENV['AWS_S3_REGION'],
          access_key_id: ENV['AWS_ACCESS_KEY_ID'],
          secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
        }
      end
    end
  end
end
