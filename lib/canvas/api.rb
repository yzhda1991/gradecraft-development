require "httparty"
require "active_support/core_ext/hash"

module Canvas
  class API
    include HTTParty
    format :json

    attr_reader :access_token, :base_uri

    def initialize(access_token, base_uri=nil)
      @access_token = access_token
      @base_uri = "#{base_uri || ENV["CANVAS_BASE_URL"]}/api/v1"
    end

    # Fetch data from Canvas
    # Optionally decide whether to automatically traverse additional pages
    def get_data(path="/", params={})
      params.merge! access_token: access_token
      next_url = "#{base_uri}#{path}"
      next_url += "?#{params.to_query}" unless params.empty?
      loop do
        # Do not add the original query parameters here since they are already
        # attached to the next url in the header
        response = self.class.get(next_url, query: { access_token: access_token })
        raise ResponseError.new(response) unless response.success?
        next_url = get_next_url(response)
        yield response.parsed_response, next_url if block_given?
        break if next_url.nil?
      end
    end

    def set_data(path="/", method=:post, params={})
      url = "#{base_uri}#{path}"
      response = self.class.send method, url, body: params.to_json,
        headers: { "Content-Type" => "application/json" },
        query: { access_token: access_token }
      raise ResponseError.new(response) unless response.success?
      yield response.parsed_response if block_given?
    end

    private

    def get_next_url(resp)
      if resp.headers["Link"]
        resp.headers["Link"].split(",").each do |link|
          matches = link.match(/^<(.*)>; rel="(.*)"/)
          unless matches.nil?
            url, rel = matches.captures
            return url if rel == "next"
          end
        end
      end
      nil
    end
  end
end
