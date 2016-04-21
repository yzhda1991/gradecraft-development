class S3ManagerStreamingTest
  include S3Manager::Streaming

  # add this so it can be stubbed in the S3Manager::Streaming spec
  def s3_object_file_key
    "some-stubbable-file-key"
  end
end
