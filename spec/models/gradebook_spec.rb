require "active_record_spec_helper"
require "db_query_matchers"

describe Gradebook do
  describe "#initialize" do
    let!(:student1) { create :user }
    let!(:student2) { create :user }

    it "initializes with a student array" do
      subject = described_class.new [student1, student2]

      expect(subject.students).to eq [student1, student2]
    end

    it "initializes with a single student" do
      subject = described_class.new student1

      expect(subject.students).to eq [student1]
    end

    it "initializes with a student list" do
      subject = described_class.new student1, student2

      expect(subject.students).to eq [student1, student2]
    end

    it "initializes with a query" do
      subject = described_class.new User.where(id: student1.id)

      expect(subject.students).to eq [student1]
    end
  end

  describe "#grades" do
    let(:student1) { create :user }
    let(:student2) { create :user }
    subject { described_class.new(student1, student2) }

    it "returns all the grades for the students" do
      grade = create :grade, student: student2

      expect(subject.grades).to eq [grade]
    end
  end

  describe "#grade" do
    let(:student1) { create :user }
    let(:student2) { create :user }
    subject { described_class.new(student1, student2) }

    it "returns a grade for a specific student" do
      grade = create :grade, student: student2

      expect(subject.grade(student2)).to eq grade
    end

    it "does not hit the database for multiple grades" do
      subject.grade(student2)

      expect { subject.grade(student1) }.to_not make_database_queries
    end

    it "returns nil for a student who is not in the gradebook" do
      expect(subject.grade(student2)).to be_nil
    end
  end
end
