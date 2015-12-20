module S3Manager
  module ObjectSummary

    class ObjectSummary
      def initialize(object_key, s3_manager)
        @object_key = object_key
        @s3_manager = s3_manager
      end

      def summary_client
        @summary_client ||= Aws::S3::ObjectSummary.new summary_client_attributes
      end

      def summary_client_attributes
        {
          bucket: @s3_manager.bucket_name,
          key: @object_key,
          client: @s3_manager.client
        }
      end

      def exists?
        summary_client.exists?
      end

      def wait_until_exists
        summary_client.wait_until_exists
      end

      def wait_until_not_exists
        summary_client.wait_until_exists
      end
    end
  end
end
