module S3Manager
  module Streaming
    def object_stream
      @object_stream ||= S3Manager::ObjectStream.new \
        object_key: s3_object_file_key
    end
  end
end
