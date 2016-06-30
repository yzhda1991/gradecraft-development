require "json"
require "webmock/rspec"
require "./lib/canvas"

describe Canvas::API do
  let(:access_token) { "BLAH" }

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
  end
end
