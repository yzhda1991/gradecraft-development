module Toolkits
  module Lib
    module LogglyResqueToolkit
      module SharedExamples
        RSpec.shared_examples "the #logger is implemented through Logglier with LogglyResque" do |target_class|
          describe "#logger" do
            subject { target_class.logger }

            let(:logger_url) { "http://some.url" }
            let(:logglier_instance) { double(Logger).as_null_object }

            before do
              allow(target_class).to receive(:logger_url) { logger_url }
            end

            before(:each) do
              target_class.instance_variable_set(:@logger, nil)
              allow(Logglier).to receive(:new) { logglier_instance }
            end

            it "builds a new logger with the logger_url and format" do
              expect(Logglier).to receive(:new).with(logger_url, {format: :json})
              subject
            end

            it "caches the logger" do
              subject
              expect(Logglier).not_to receive(:new).with(logger_url, {format: :json})
              subject
            end

            it "sets the logger value to @logger" do
              subject
              expect(target_class.instance_variable_get(:@logger)).to eq(logglier_instance)
            end
          end

          # build a url of the folliwing format:
          # https://logs-01.loggly.com/inputs/<loggly-token>/tag/tag-name
          #
          #  def logger_url
          #    [ logger_base_url, ENV["LOGGLY_TOKEN"], "tag", queue_tag_name ].join("/")
          #  end
          #
          describe "#logger_url" do
            subject { target_class.logger_url }

            let(:logger_base_url) { "http://some.base.url" }
            let(:queue_tag_name) { "some-app-environmentname" }
            let!(:cached_loggly_token) { ENV["LOGGLY_TOKEN"] } # cache the loggly token to reset later

            before do
              allow(target_class).to receive_messages(logger_base_url: logger_base_url, queue_tag_name: queue_tag_name)
              ENV["LOGGLY_TOKEN"] = "some_bogus_token"
            end

            it "builds a target url for the logger" do
              expect(subject).to eq [ logger_base_url, "some_bogus_token", "tag", queue_tag_name ].join("/")
            end

            after do
              # reset this for use in other specs
              ENV["LOGGLY_TOKEN"] = cached_loggly_token
            end
          end

          describe "#logger_base_url" do
            subject { target_class.logger_base_url }
            it "returns the de facto base url for the loggly api" do
              expect(subject).to eq("https://logs-01.loggly.com/inputs")
            end
          end

          #  def queue_tag_name
          #    [ @queue.to_s.gsub(/_+/,"-"), LOGGLY_CONFIG["TAG_SUFFIX"] ].join("-")
          #  end
          describe "#queue_tag_name" do
            subject { target_class.queue_tag_name }
            let(:loggly_tag_suffix) { "some-weird-stuff" }
            let(:formatted_queue_name) { target_class.instance_variable_get(:@queue).to_s.gsub(/_+/, "-") }
            let!(:cached_loggly_tag_suffix) { LOGGLY_CONFIG["TAG_SUFFIX"] }

            before { LOGGLY_CONFIG["TAG_SUFFIX"] = loggly_tag_suffix }

            it "builds a queue tag name from the queue name and the loggly config tag suffix" do
              expect(subject).to eq "#{formatted_queue_name}-#{loggly_tag_suffix}"
            end

            after { LOGGLY_CONFIG["TAG_SUFFIX"] = cached_loggly_tag_suffix }
          end
        end
      end
    end
  end
end
