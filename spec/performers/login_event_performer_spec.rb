require 'rails_spec_helper'
require "mongoid_spec_helper"

describe LoginEventPerformer do
  subject { described_class.new }

  # these are the attributes needed to skip #setup so we can test methods
  # explicitly: LoginEventPerformer#initialize(data_hash, logger, options)
  let(:skip_setup_attrs) do
    [{}, nil, skip_setup: true]
  end

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
      subject { described_class.new *skip_setup_attrs }

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

      # these specs are relying on the fact that this is a valid set of
      # attributes for an Analytics::LoginEvent object
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

  describe "managing :last_login_at" do
    subject { described_class.new *skip_setup_attrs }

    let(:login_time) { Time.parse("Oct 20 2020") }

    before do
      allow(subject).to receive(:course_membership) { course_membership }
    end

    describe "#cache_last_login_at" do
      let(:course_membership) do
        double(CourseMembership, last_login_at: login_time).as_null_object
      end

      it "adds the :last_login_at value to :data from the CourseMembership" do
        subject.cache_last_login_at
        expect(subject.data[:last_login_at])
          .to eq course_membership.last_login_at.to_i
      end

      context "CourseMembership#last_login_at doesn't exist" do
        let(:login_time) { nil }
        it "returns nil" do
          subject.cache_last_login_at
          expect(subject.data[:last_login_at]).to be_nil
        end
      end
    end

    describe "#update_course_membership_login" do
      context "data[:created_at] doesn't exist" do
        it "returns false" do
          subject.data[:created_at] = nil
          expect(subject.update_course_membership_login).to eq false
        end
      end

      context "data[:created_at] exists" do
        let(:course_membership) { create(:course_membership, :student) }

        it "updates the course membership :last_login_at time" do
          subject.data[:created_at] = login_time
          subject.update_course_membership_login
          expect(course_membership.last_login_at).to eq login_time
        end
      end
    end
  end

  describe "#find_course_membership" do
    subject { described_class.new *skip_setup_attrs }

    before(:each) do
      allow(subject).to receive(:course_membership_attrs)
        .and_return course_membership_attrs
    end

    context "not all necessary course membership attributes are present" do
      let(:course_membership_attrs) { { user_id: nil, course_id: nil } }
      it "returns nil" do
        expect(subject.find_course_membership).to be_nil
      end
    end

    context "all course membership attributes are present" do
      let(:course_membership) { create(:course_membership, :student) }
      let(:course_membership_attrs) do
        { user_id: course_membership.user_id,
          course_id: course_membership.course_id }
      end

      it "finds the course membership by the correct attributes" do
        expect(subject.find_course_membership).to eq course_membership
      end
    end
  end

  describe "#course_membership_attrs" do
    it "returns a hash with :user_id and :course_id taken from #data" do
      subject.data[:user_id] = 20
      subject.data[:course_id] = 30
      expect(subject.course_membership_attrs)
        .to eq({ user_id: 20, course_id: 30 })
    end
  end

  describe "#messages" do
    it "builds a success message including #data" do
      expect(subject.messages[:success]).to eq \
        "Successfully logged login event with data #{subject.data}"
    end

    it "builds a failure message including #data" do
      expect(subject.messages[:failure]).to eq \
        "Failed to log login event with data #{subject.data}"
    end
  end
end
