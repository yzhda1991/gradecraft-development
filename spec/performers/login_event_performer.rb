require "rails_spec_helper"

RSpec.describe LoginEventPerformer, type: :performer do
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
      let(:course_membership) { double(CourseMembership).as_null_object }

      it "finds the course membership" do
        allow_any_instance_of(described_class).to receive( \
          :find_course_membership) { course_membership }
        expect(subject.course_membership).to eq course_membership
      end

      context "CourseMembership is nil" do
        # let's build a new logger here but skip #setup so we can test it
        # explicitly: LoginEventPerformer#initialize(data_hash, logger, options)
        subject { described_class.new({}, nil, skip_setup: true) }

        it "returns from the setup" do
          expect(subject).not_to receive(:cache_last_login_at)
          expect(subject.setup).to be_nil
        end
      end

      context "CourseMembership is present" do
        it "caches the :last_login_at value from the CourseMembership" do
        end

        it "updates the CourseMembership with the new last_login_at value" do
        end
      end
    end

  end
end
