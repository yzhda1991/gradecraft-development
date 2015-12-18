module S3Manager
  # requires S3Manager::Basics
  module ConsoleTests
    def push_test_object
      encrypted_s3_client.put_object s3_object_attrs.merge(server_side_encryption: "AES256", key: "some-rando-key", body: "some rando content.")
    end

    def push_test_object_pair(key, body)
      encrypted_s3_client.put_object s3_object_attrs.merge(server_side_encryption: "AES256", key: key, body: body)
    end

    def get_test_object(object_key)
      encrypted_s3_client.get_object s3_object_attrs.merge(key: object_key)
    end
  end
end
