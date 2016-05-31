module S3Manager
  module Streaming
    def object_stream
      @object_stream ||= S3Manager::ObjectStream.new \
        object_key: s3_object_file_key
    end

    def streamable?
      return false unless object_stream && object_stream.object
      object_stream.exists?
    end

    def stream!
      return false unless streamable?
      object_stream.stream!
    end
  end
end
