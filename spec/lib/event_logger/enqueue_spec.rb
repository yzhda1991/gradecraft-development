require "active_record_spec_helper"
require "resque_spec/scheduler"
require_relative "../../support/test_classes/lib/event_logger/test_event_logger"

describe EventLogger::Enqueue, type: :vendor_library do
  include InQueueHelper

  let(:course) { build(:course) }
  let(:user) { build(:user) }
  let(:student) { build(:user) }
  let(:request) { double(:request) }

  let(:event_session) {{
    course: course,
    user: user,
    student: student,
    request: request
  }}

  describe TestEventLogger do
    subject { described_class.new event_session }

    describe "#initialize" do
      it "should set an @event_session hash" do
        expect(subject.instance_variable_get(:@event_session))
          .to eq(event_session)
        subject
      end
    end

    describe "enqueuing" do
      let(:event_attrs) { subject.event_attrs }

      before(:each) do
        ResqueSpec.reset!
      end

      describe "enqueue without schedule" do
        it "should find a job in the TestEventLogger queue" do
          subject.enqueue
          resque_job = Resque.peek(:test_event_logger)
          expect(resque_job).to be_present
        end

        it "should have a TestEventLogger event in the queue" do
          subject.enqueue
          expect(described_class).to have_queue_size_of(1)
        end
      end

      describe "#enqueue with schedule" do
        describe"enqueue_in" do
          it "should schedule a TestEventLogger event" do
            subject.enqueue_in(2.hours)
            expect(described_class).to have_scheduled("test", event_attrs).in(2.hours)
          end
        end

        describe "#enqueue_at" do
          let(:later) { Time.parse "Feb 10 2052" }

          it "should enqueue the login logger to trigger :later" do
            subject.enqueue_at later
            expect(described_class).to have_scheduled("test", event_attrs).at later
          end
        end

        describe "#enqueue_in_with_fallback" do
          let(:result) { subject.enqueue_in_with_fallback(2.hours) }

          it "should schedule a TestEventLogger event" do
            result
            expect(described_class).to have_scheduled("test", event_attrs).in(2.hours)
          end

          context "Resque reaches Redis correctly and no error is thrown" do
            it "doesn't call TestEventLogger#perform directly" do
              expect(described_class).not_to receive(:perform).with("test", event_attrs)
              result
            end
          end

          context "Resque can't reach Redis and throws an error" do
            before do
              allow(subject).to receive(:enqueue_in)
                .and_raise("FAKE RSPEC ERROR: Could not connect to Redis: " \
                  "getaddrinfo socket error.")
            end

            it "calls #{described_class}#perform directly" do
              expect(described_class).to receive(:perform).with("test", event_attrs)
              result
            end
          end
        end

        describe "#enqueue_with_fallback" do
          let(:result) { subject.enqueue_with_fallback }

          context "Resque reaches Redis correctly and no error is thrown" do
            it "should find a job in the TestEventLogger queue" do
              result
              resque_job = Resque.peek(:test_event_logger)
              expect(resque_job).to be_present
            end

            it "should have a TestEventLogger event in the queue" do
              result
              expect(described_class).to have_queue_size_of(1)
            end

            it "doesn't call TestEventLogger.perform directly" do
              expect(described_class).not_to receive(:perform).with("test", event_attrs)
              result
            end
          end

          context "Resque can't reach Redis and throws an error" do
            before do
              allow(subject).to receive(:enqueue).and_raise("FAKE RSPEC ERROR:" \
                "Could not connect to Redis: getaddrinfo socket error.")
            end

            it "calls TestEventLogger#perform directly" do
              expect(described_class).to receive(:perform).with("test", event_attrs)
              result
            end
          end
        end
      end
    end
  end
end
