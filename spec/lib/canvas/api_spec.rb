describe Canvas::API, type: :disable_external_api do
  let(:access_token) { "BLAH" }
  let(:base_uri) { "https://thecanvas.instructure.com" }

  ENV["CANVAS_BASE_URL"] = "https://canvas.instructure.com"

  describe "#initialize" do
    it "initializes with an access token" do
      expect(described_class.new(access_token).access_token).to eq access_token
      expect(described_class.new(access_token).base_uri).to eq \
        "https://canvas.instructure.com/api/v1"
    end

    it "initializes with options" do
      expect(described_class.new(access_token, base_uri).base_uri).to eq \
        "https://thecanvas.instructure.com/api/v1"
    end
  end

  describe "#get_data" do
    subject { described_class.new(access_token) }

    it "retrieves the data from the specified path" do
      stub = stub_request(:get, "https://canvas.instructure.com/api/v1/courses")
        .with(query: { "access_token" => access_token })
        .to_return(status: 200, body: {}.to_json, headers: {})

      subject.get_data("/courses")

      expect(stub).to have_been_requested
    end

    it "allows for parameters" do
      stub = stub_request(:get, "https://canvas.instructure.com/api/v1/courses")
        .with(query: { "enrollment_type" => "teacher", "access_token" => access_token })
        .to_return(status: 200, body: {}.to_json, headers: {})

      subject.get_data("/courses", enrollment_type: :teacher)

      expect(stub).to have_been_requested
    end

    it "raises an exception when a request fails" do
      body = { errors: [{ message: "Invalid access token." }] }
      stub = stub_request(:get, "https://canvas.instructure.com/api/v1/courses")
        .with(query: { "access_token" => access_token })
        .to_return(status: 401, body: body.to_json, headers: {})

      expect { subject.get_data("/courses") }.to \
        raise_error Canvas::ResponseError, "Invalid access token."
    end

    it "returns the data in a block" do
      body = { name: "This is a course" }

      stub = stub_request(:get, "https://canvas.instructure.com/api/v1/courses")
        .with(query: { "access_token" => access_token })
        .to_return(status: 200, body: body.to_json, headers: {})

      result = nil
      subject.get_data("/courses") { |course| result = course }

      expect(result["name"]).to eq "This is a course"
    end

    it "automatically traverses all pages by default" do
      links = <<-LINKS
      <https://canvas.instructure.com/api/v1/courses?enrollment_type=student&page=1&per_page=10>; rel="current",<https://canvas.instructure.com/api/v1/courses?enrollment_type=student&page=2&per_page=10>; rel="next"
      LINKS
      headers = { "Link" => links }

      body1 = { name: "This is a course on page 1" }
      first_request = stub_request(:get, "https://canvas.instructure.com/api/v1/courses")
        .with(query: { "enrollment_type" => "student", "access_token" => access_token })
        .to_return(status: 200, body: body1.to_json, headers: headers)

      body2 = { name: "This is a course on page 2" }
      second_request = stub_request(:get, "https://canvas.instructure.com/api/v1/courses")
        .with(query: { "page" => "2", "per_page" => "10", "enrollment_type" => "student",
                       "access_token" => access_token })
        .to_return(status: 200, body: body2.to_json, headers: {})

      grades = []
      subject.get_data("/courses", enrollment_type: :student) { |course| grades << course }

      expect(grades.count).to eq 2
      expect(first_request).to have_been_made
      expect(second_request).to have_been_made
    end
  end

  describe "#set_data" do
    subject { described_class.new(access_token) }

    it "updates the data from the specified path" do
      params = { name: "Blah" }
      stub = stub_request(:put, "https://canvas.instructure.com/api/v1/courses/123")
        .with(query: { "access_token" => access_token }, body: params.to_json)
        .to_return(status: 200, body: {}.to_json, headers: {})

      subject.set_data("/courses/123", :put, params)

      expect(stub).to have_been_requested
    end

    it "raises an exception when a request fails" do
      body = { errors: [{ message: "Invalid access token." }] }
      stub = stub_request(:post, "https://canvas.instructure.com/api/v1/courses")
        .with(query: { "access_token" => access_token })
        .to_return(status: 401, body: body.to_json, headers: {})

      expect { subject.set_data("/courses", :post) }.to \
        raise_error Canvas::ResponseError, "Invalid access token."
    end

    it "returns the data in a block" do
      body = { name: "This is a course" }

      stub = stub_request(:post, "https://canvas.instructure.com/api/v1/courses")
        .with(query: { "access_token" => access_token })
        .to_return(status: 200, body: body.to_json, headers: {})

      result = nil
      subject.set_data("/courses") { |course| result = course }

      expect(result["name"]).to eq "This is a course"
    end
  end
end
