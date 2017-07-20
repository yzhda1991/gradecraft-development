module Toolkits
  module Lib
    module PapertrailResqueToolkit
      module SharedExamples
        RSpec.shared_examples "the #logger is implemented through Papertrail with PapertrailResque" do |target_class|
          describe "#logger" do
            subject { target_class.logger }

            let(:papertrail_instance) { double(Logger).as_null_object }

            before(:each) do
              target_class.instance_variable_set(:@logger, nil)
              allow(RemoteSyslogLogger).to receive(:new) { papertrail_instance }
            end

            it "builds a new logger" do
              expect(RemoteSyslogLogger).to \
                receive(:new).with(String, Integer, program: "jobs-test")
              subject
            end

            it "caches the logger" do
              subject
              expect(RemoteSyslogLogger).not_to receive(:new)
              subject
            end

            it "sets the logger value to @logger" do
              subject
              expect(target_class.instance_variable_get(:@logger)).to \
                eq(papertrail_instance)
            end
          end
        end
      end
    end
  end
end
