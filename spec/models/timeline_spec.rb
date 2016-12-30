require "active_record_spec_helper"

describe Timeline do
  let(:course) { create :course }
  subject { described_class.new(course) }

  describe "#initialize" do
    it "is initialized with a course" do
      expect(subject.course).to eq course
    end
  end

  describe "#events" do
    context "with assignments for the course" do
      let!(:assignment) { create :assignment, course: course, due_at: Date.today }
      let!(:assignment_not_due) { create :assignment, course: course, due_at: nil }

      it "includes the assignments" do
        expect(subject.events).to eq [assignment]
      end
    end

    context "with events for the course" do
      let!(:event) { create :event, course: course, due_at: Date.today }

      it "includes the events" do
        expect(subject.events).to eq [event]
      end
    end

    context "with challenges for the course" do
      let!(:challenge) { create :challenge, course: course, due_at: Date.today, include_in_timeline: true }
      let!(:challenge_not_due) { create :challenge, course: course, due_at: nil }

      context "that accepts team challenges" do
        before { course.update_attributes has_team_challenges: true }

        it "includes the challenges" do
          expect(subject.events).to eq [challenge]
        end
      end

      context "that does not accept team challenges" do
        it "does not include the challenges" do
          expect(subject.events).to eq []
        end
      end
    end
  end
end
