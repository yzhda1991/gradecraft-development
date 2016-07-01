module Canvas
  class ResponseError < StandardError
    def initialize(response)
      body = JSON.parse(response.body)
      errors = body["errors"]
      super errors.first["message"] unless errors.nil?
    end
  end
end
