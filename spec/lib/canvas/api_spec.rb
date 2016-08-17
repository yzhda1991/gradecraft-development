require "api_spec_helper"
require "./lib/canvas"

describe Canvas::API, type: :disable_external_api do
  let(:access_token) { "BLAH" }

  before do
    allow(Canvas::API).to \
      receive(:base_uri).and_return "https://canvas.instructure.com/api/v1"
  end

  describe "#initialize" do
    it "initializes with an access token" do
      expect(described_class.new(access_token).access_token).to eq access_token
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

    it "automatically traverses the pages" do
      links = <<-LINKS
      <https://canvas.instructure.com/api/v1/courses?page=1&per_page=10>; rel="current",<https://canvas.instructure.com/api/v1/courses?page=2&per_page=10>; rel="next"
      LINKS
      headers = { "Link" => links }

      body1 = { name: "This is a course on page 1" }
      first_stub = stub_request(:get, "https://canvas.instructure.com/api/v1/courses")
        .with(query: { "access_token" => access_token })
        .to_return(status: 200, body: body1.to_json, headers: headers)

      body2 = { name: "This is a course on page 2" }
      first_stub = stub_request(:get, "https://canvas.instructure.com/api/v1/courses")
        .with(query: { "page" => "2", "per_page" => "10", "access_token" => access_token })
        .to_return(status: 200, body: body2.to_json, headers: {})

      result = []
      subject.get_data("/courses") { |course| result << course }

      expect(result.count).to eq 2
    end
  end
end
