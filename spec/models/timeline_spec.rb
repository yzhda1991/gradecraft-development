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
    it "includes assignments that have due dates or open dates" do
      assignment = create(:assignment, course: course, due_at: Date.today)
      assignment_no_date = create(:assignment, course: course, due_at: nil)
      expect(subject.events).to eq [assignment]
    end

    it "includes events that have due dates or open dates" do
      event = create(:event, course: course, due_at: Date.today)
      event_no_date = create(:event, course: course, due_at: nil)
      expect(subject.events).to eq [event]
    end

    it "includes challenge that have due dates or open dates if the course allows it" do
      course.update_attributes team_challenges: true
      challenge = create(:challenge, course: course, due_at: Date.today)
      challenge_no_date = create(:challenge, course: course, due_at: nil)
      expect(subject.events).to eq [challenge]
    end

    it "does not include challenge that have due dates or open dates if the course does not allows it" do
      challenge = create(:challenge, course: course, due_at: Date.today)
      challenge_no_date = create(:challenge, course: course, due_at: nil)
      expect(subject.events).to eq []
    end
  end
end
