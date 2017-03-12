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
              expect(subject).not_to receive(:fallback)
              result
            end
          end

          context "any exception is thrown" do
            it "doesn't fallback" do
              allow(subject).to receive(:enqueue_in).and_raise "FAKE ERROR"
              expect(subject).not_to receive(:fallback)
              expect { result }.to raise_error "FAKE ERROR"
            end
          end

          context "a Redis::BaseError is thrown" do
            it "falls back" do
              allow(subject).to receive(:enqueue_in).and_raise Redis::BaseError
              expect(subject).to receive(:fallback)
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
              expect(subject).not_to receive(:fallback)
              result
            end
          end

          context "any exception is thrown" do
            it "doesn't fallback" do
              allow(subject).to receive(:enqueue).and_raise "FAKE ERROR"
              expect(subject).not_to receive(:fallback)
              expect { result }.to raise_error "FAKE ERROR"
            end
          end

          context "a Redis::BaseError is thrown" do
            it "falls back" do
              allow(subject).to receive(:enqueue).and_raise Redis::BaseError
              expect(subject).to receive(:fallback)
              result
            end
          end
        end

        describe "#fallback" do
          it "calls perform on the included class with the event_attrs" do
            expect(described_class).to receive(:perform).with("test", event_attrs)
            subject.fallback
          end
        end
      end
    end
  end
end
