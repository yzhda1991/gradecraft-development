module Toolkits
  module EventLoggers
    module SharedExamples

      RSpec.shared_examples "EventLogger::Enqueue is included" do |logger_class, logger_name|
        describe "#initialize" do
          subject { new_logger }

          it "should set an @event_session hash" do
            expect(subject.instance_variable_get(:@event_session)).to eq(event_session)
          end
        end

        describe "enqueuing" do
          let(:event_attrs) { new_logger.event_attrs }

          before(:each) do
            ResqueSpec.reset!
          end

          describe "enqueue without schedule" do
            before(:each) { new_logger.enqueue }

            it "should find a job in the #{logger_name} queue" do
              resque_job = Resque.peek(:"#{logger_name}_event_logger")
              expect(resque_job).to be_present
            end

            it "should have a #{logger_name} logger event in the queue" do
              expect(logger_class).to have_queue_size_of(1)
            end
          end

          describe "#enqueue with schedule" do
            describe"enqueue_in" do
              subject { new_logger.enqueue_in(2.hours) }

              it "should schedule a #{logger_name} event" do
                subject
                expect(logger_class).to have_scheduled(logger_name, event_attrs).in(2.hours)
              end
            end

            describe "#enqueue_at" do
              let!(:"#{logger_name}_event_logger") { new_logger.enqueue_at later }
              let(:later) { Time.parse "Feb 10 2052" }

              it "should enqueue the login logger to trigger :later" do
                expect(logger_class).to have_scheduled(logger_name, event_attrs).at later
              end
            end

            describe "#enqueue_in_with_fallback" do
              subject { new_logger.enqueue_in_with_fallback(2.hours) }

              it "should schedule a #{logger_name} event" do
                subject
                expect(logger_class).to have_scheduled(logger_name, event_attrs).in(2.hours)
              end

              context "Resque reaches Redis correctly and no error is thrown" do
                it "doesn't call #{logger_class}#perform directly" do
                  expect(logger_class).not_to receive(:perform).with(logger_name, event_attrs)
                  subject
                end
              end

              context "Resque can't reach Redis and throws an error" do
                before do
                  allow(new_logger).to receive(:enqueue_in).and_raise("FAKE RSPEC ERROR: Could not connect to Redis: getaddrinfo socket error.")
                end

                it "calls #{logger_class}#perform directly" do
                  expect(logger_class).to receive(:perform).with(logger_name, event_attrs)
                  subject
                end
              end
            end

            describe "#base_attrs" do
              subject { new_logger.base_attrs }

              let(:expected_base_attrs) {{
                course_id: event_session[:course].id,
                user_id: event_session[:user].id,
                student_id: event_session[:student].id,
                user_role: "great-role",
                created_at: time_zone_now
              }}

              let(:time_zone_now) { Date.parse("June 9 1900") }

              before do
                allow(Time.zone).to receive(:now) { time_zone_now }
                allow(event_session[:user]).to receive(:role).with(event_session[:course]) { "great-role" }
              end

              it "returns a hash of default attributes for session events" do
                expect(subject).to eq(expected_base_attrs)
              end

              it "caches the attributes hash" do
                subject
                expect(event_session[:user]).not_to receive(:role)
                subject
              end

              it "sets the hash to @base_attrs" do
                subject
                expect(new_logger.instance_variable_get(:@base_attrs)).to eq(expected_base_attrs)
              end
            end

          end
        end
      end

      RSpec.shared_examples "an EventLogger subclass" do |logger_class, logger_name|

        describe "class-level instance variables" do
          describe "@queue" do
            it "uses the #{logger_name}_event_logger queue" do
              expect(logger_class.instance_variable_get(:@queue)).to eq(:"#{logger_name}_event_logger")
            end
          end

          describe "@event_name" do
            it "uses #{logger_name.capitalize} as an event name for messaging" do
              expect(logger_class.instance_variable_get(:@event_name)).to eq(logger_name.capitalize)
            end
          end
        end

        describe "#event_type" do
          it "provides '#{logger_name}' as an event type" do
            expect(new_logger.event_type).to eq(logger_name)
          end
        end

      end

    end
  end
end



