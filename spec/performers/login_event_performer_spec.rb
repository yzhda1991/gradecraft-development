require 'rails_spec_helper'
# require 'active_record_spec_helper'
# require_relative '../../lib/is_configurable'
# require_relative '../../lib/loggly_resque'
# require_relative '../../lib/inheritable_ivars'
# require_relative '../../lib/resque_job'
# require_relative '../../app/performers/login_event_performer'

describe LoginEventPerformer do
  subject { described_class.new }

  it "should inherit from ResqueJob::Performer" do
    expect(described_class.superclass).to eq ResqueJob::Performer
  end

  describe "accessible attributes" do
    it "has an accessible :data hash" do
      subject.data = "something"
      expect(subject.data).to eq "something"
    end

    it "has an accessible :user_id" do
      subject.user_id = 20
      expect(subject.user_id).to eq 20
    end

    it "has an accessible :course_id" do
      subject.course_id = 30
      expect(subject.course_id).to eq 30
    end

    it "has an accessible :course_membership" do
      subject.course_membership = "some course membership"
      expect(subject.course_membership).to eq "some course membership"
    end
  end

  describe "#setup" do
    context "#attrs[:data] is a hash" do
      subject { described_class.new data: { waffle_id: 20 } }

      it "returns the value of attrs[:data]" do
        expect(subject.data).to eq({ waffle_id: 20 })
      end
    end

    context "#attrs[:data] is not a hash" do
      subject { described_class.new data: "snakes" }

      it "returns an empty hash" do
        expect(subject.data).to eq({})
      end
    end

    describe "finding the course membership" do
      # let's build a new logger here but skip #setup so we can test it
      # explicitly: LoginEventPerformer#initialize(data_hash, logger, options)
      subject { described_class.new({}, nil, skip_setup: true) }

      let(:course_membership) { double(CourseMembership).as_null_object }
      let(:stub_valid_course_membership) do
        allow_any_instance_of(described_class).to \
          receive(:find_course_membership) { course_membership }
      end

      it "finds the course membership" do
        stub_valid_course_membership
        expect(subject.course_membership).to eq course_membership
      end

      context "CourseMembership is nil" do
        it "returns from the setup" do
          expect(subject).not_to receive(:cache_last_login_at)
          expect(subject.setup).to be_nil
        end
      end

      context "CourseMembership is present" do
        before  { stub_valid_course_membership }

        it "caches the :last_login_at value from the CourseMembership" do
          expect(subject).to receive(:cache_last_login_at)
          subject.setup
        end

        it "updates the CourseMembership with the new last_login_at value" do
          expect(subject).to receive(:update_course_membership_login)
          subject.setup
        end
      end
    end
  end

  describe ".perform" do
    it "requires success" do
      expect(subject).to receive(:require_success).with(subject.messages)
      subject.perform
    end

    it "returns an outcome" do
      expect(subject.perform.class).to eq ResqueJob::Outcome
    end

    context "data[:user_role] is present" do
      subject { described_class.new data: data }

      let(:data) do
        { user_role: "some_role", created_at: Time.now, event_type: "foo" }
      end
      let(:login_event) { double(Analytics::LoginEvent).as_null_object }

      it "adds a login event record to mongo" do
        expect { subject.perform }
          .to change { Analytics::LoginEvent.count }.by 1
      end

      it "creates a new login event" do
        expect(Analytics::LoginEvent).to receive(:create) { login_event }
        subject.perform
      end

      it "returns an outcome" do
        expect(subject.perform.class).to eq ResqueJob::Outcome
      end

      describe "login event outcomes" do
        before do
          allow(Analytics::LoginEvent).to receive(:create) { login_event }
        end

        context "the login event is not valid" do
          it "returns an outcome with a false result" do
            allow(login_event).to receive(:valid?) { false }
            expect(subject.perform.result).to eq false
          end
        end

        context "the login event is valid" do
          it "returns an outcome with a true result" do
            allow(login_event).to receive(:valid?) { true }
            expect(subject.perform.result).to eq true
          end
        end
      end
    end

    context "data[:user_role] is not present" do
      subject { described_class.new data: { waffle_id: 20 } }

      it "returns a false outcome" do
        expect(subject.perform.result).to eq false
      end
    end
  end
end
