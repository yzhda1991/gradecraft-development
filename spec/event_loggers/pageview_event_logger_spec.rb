RSpec.describe PageviewEventLogger, type: :event_logger do
  subject { described_class.new(request: request) }
  let(:request) { double(:request).as_null_object }

  before do
    allow(Time).to receive(:now) { Date.parse("Oct 20 1999").to_time }
  end

  it "has a queue" do
    expect(described_class.queue).to eq :pageview_event_logger
  end

  it "has an accessible :page attribute" do
    subject.page = "waffles"
    expect(subject.page).to eq "waffles"
  end

  it "includes EventLogger::Enqueue" do
    expect(subject).to respond_to(:enqueue_in_with_fallback)
  end

  it "has an #event_type" do
    expect(subject.event_type).to eq "pageview"
  end

  it "inherits from the ApplicationEventLogger" do
    expect(described_class.superclass).to eq ApplicationEventLogger
  end

  describe "#event_attrs" do
    before do
      allow(subject).to receive(:page) { "some great page" }
    end

    it "merges the page from the original request with the application_attrs" do
      expect(subject.event_attrs).to eq \
        subject.application_attrs.merge(page: "some great page")
    end
  end

  describe "#page" do
    let(:result) { subject.page }
    let(:request_path) { "/path/to/chaos" }

    before do
      allow(request).to receive(:original_fullpath) { request_path }
    end

    it "gets the original fullpath from the request" do
      expect(result).to eq request_path
    end

    it "caches the #page" do
      result
      expect(request).not_to receive(:try).with(:original_fullpath)
      result
    end

    it "sets the page to @page" do
      result
      expect(subject.instance_variable_get(:@page)).to eq(request_path)
    end
  end

  describe "#build_page_from_params" do
    let(:result) { subject.build_page_from_params }
    before(:each) { allow(subject).to receive(:params) { params } }

    context "params exists" do
      context "neither params[:url] nor params[:tab] exist" do
        let(:params) { { stuff: "dude" } }
        it "returns nil" do
          expect(result).to be_nil
        end
      end

      context "params[:url] and params[:tab] both exist" do
        let(:params) { { url: "http://some.url", tab: "#greatness" } }

        it "builds a string from the params :url and :tab values" do
          expect(result).to eq "http://some.url#greatness"
        end

        it "sets @page to the string built from \#{url}\#{tab}" do
          result
          expect(subject.page).to eq "http://some.url#greatness"
        end
      end
    end

    context "params does not exist" do
      let(:params) { nil }
      it "returns nil" do
        expect(result).to be_nil
      end
    end
  end
end
