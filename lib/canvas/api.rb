require "net/http"

module Canvas
  class API
    attr_reader :access_token

    def initialize(access_token)
      @access_token = access_token
      @url_base = "https://canvas.instructure.com/api/v1"
    end

    def get_data(path="/", params={})
      params[:access_token] = access_token
      next_url = "#{@url_base}#{path}"
      while next_url
        uri = get_uri(next_url, params)
        resp = Net::HTTP.get_response(uri)
        fail "An error occured #{resp}" unless resp.is_a? Net::HTTPOK
        yield JSON.parse(resp.body) if block_given?
        next_url = get_next_url resp
      end
    end

    private

    def get_next_url(resp)
      if resp["Link"]
        resp["Link"].split(",").each do |link|
          matches = link.match(/^<(.*)>; rel="(.*)"/)
          unless matches.nil?
            url, rel = matches.captures
            return url if rel == "next"
          end
        end
      end
      nil
    end

    def get_uri(url, params = {})
      uri = URI(url)

      uri.query = if uri.query.is_a? String
                    "#{uri.query}&#{URI.encode_www_form(params)}"
                  else
                    URI.encode_www_form(params)
                  end
      uri
    end
  end
end
