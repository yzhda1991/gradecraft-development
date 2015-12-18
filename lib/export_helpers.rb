# @mz todo: add specs
module ExportHelpers
  module S3
    extend ActiveSupport::Concern

    def s3_client
      @s3_client ||= Aws::S3::Client.new({
        region: ENV['AWS_S3_REGION'],
        access_key_id: ENV['AWS_ACCESS_KEY_ID'],
        secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
      })
    end

    def s3_resource
      @s3_resource ||= Aws::S3::Resource.new
    end

    def s3_bucket
      s3_client
      @s3_bucket ||= s3_resource.bucket(s3_bucket_name)
    end

    def s3_bucket_name
      @s3_bucket_name ||= "gradecraft-#{Rails.env}"
    end

    def kms_client
      @kms_client ||= Aws::KMS::Client.new
    end

    def kms_key_id
      @kms_key_id ||= kms_client.create_key.key_metadata.key_id
    end

    def encrypted_s3_client
      encrypted_s3_client ||= Aws::S3::Encryption::Client.new(
        kms_key_id: kms_key_id,
        kms_client: kms_client,
        client: s3_client
      )
    end

    def push_test_object
      encrypted_s3_client.put_object s3_object_attrs.merge(server_side_encryption: "AES256", key: "some-rando-key", body: "some rando content.")
    end

    def push_test_object_pair(key, body)
      encrypted_s3_client.put_object s3_object_attrs.merge(server_side_encryption: "AES256", key: key, body: body)
    end

    def get_test_object(object_key)
      encrypted_s3_client.get_object s3_object_attrs.merge(key: object_key)
    end

    def s3_object_attrs
      {
        bucket: s3_bucket_name
      }
    end

    def s3_object_key
      "#{s3_object_key_path}/#{export_filename}"
    end

    def s3_object_key_path
      "/exports"
    end

    def s3_object
      @s3_object ||= s3_bucket.object(s3_object_key)
    end

    def s3_object_key
      "#{s3_object_key_path}/#{export_filename}"
    end
  end
end

