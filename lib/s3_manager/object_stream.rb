module S3Manager
  class ObjectStream
    include S3Manager::Basics

    attr_accessor :object_key

    def initialize(object_key:)
      @object_key = object_key
    end

    def object
      @object ||= get_object object_key
    end

    def exists?
      object and object.body
    end

    def stream!
      object.body.read
    end
  end
end
