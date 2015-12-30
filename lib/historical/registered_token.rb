module Historical
  class RegisteredToken
    attr_reader :type, :selector

    def initialize(type, selector)
      @type = type
      @selector = selector
    end

    def create(key, value, object_type)
      type.new key, value, object_type
    end
  end
end
