module Canvas
  class ResponseError < StandardError
    def initialize(response)
      body = response.parsed_response
      errors = body["errors"]
      super errors.first["message"] unless errors.nil? || errors.empty?
    end
  end
end
