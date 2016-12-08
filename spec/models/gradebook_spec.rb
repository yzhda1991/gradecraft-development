require "active_record_spec_helper"
require "db_query_matchers"

describe Gradebook do
  let(:assignment) { create :assignment }

  describe "#initialize" do
    let!(:student1) { create :user }
    let!(:student2) { create :user }

    it "initializes with an assignment" do
      subject = described_class.new assignment

      expect(subject.assignment).to eq assignment
    end

    it "initializes with a student array" do
      subject = described_class.new assignment, [student1, student2]

      expect(subject.students).to eq [student1, student2]
    end

    it "initializes with a single student" do
      subject = described_class.new assignment, student1

      expect(subject.students).to eq [student1]
    end

    it "initializes with a student list" do
      subject = described_class.new assignment, student1, student2

      expect(subject.students).to eq [student1, student2]
    end

    it "initializes with a query" do
      subject = described_class.new assignment, User.where(id: student1.id)

      expect(subject.students).to eq [student1]
    end
  end

  describe "#existing_grades" do
    let(:student1) { create :user }
    let(:student2) { create :user }
    subject { described_class.new(assignment, student1, student2) }

    it "returns all the exising grades for the assignment and students" do
      grade = create :grade, assignment: assignment, student: student2

      expect(subject.existing_grades).to eq [grade]
    end

    it "only includes existing grades for the specified assignment" do
      grade = create :grade, student: student2

      expect(subject.existing_grades).to be_empty
    end
  end

  describe "#grades" do
    let(:student1) { create :user, first_name: "John", last_name: "Doe" }
    let(:student2) { create :user, first_name: "Jane", last_name: "Doe" }
    subject { described_class.new(assignment, student1, student2) }

    it "includes the existing grades" do
      grade1 = create :grade, assignment: assignment, student: student1
      grade2 = create :grade, assignment: assignment, student: student2

      expect(subject.grades.count).to eq 2
      expect(subject.grades).to include grade1
      expect(subject.grades).to include grade2
    end

    it "adds any missing grades" do
      grade = create :grade, assignment: assignment, student: student1

      expect(subject.grades.count).to eq 2
      expect(subject.grades).to include grade
      expect(subject.grades.select(&:new_record?).count).to eq 1
    end

    it "sorts the grades by student names" do
      grade = create :grade, assignment: assignment, student: student1

      expect(subject.grades.map(&:student)).to eq [student2, student1]
    end
  end

  describe "#grade" do
    let(:student1) { create :user }
    let(:student2) { create :user }
    subject { described_class.new(assignment, student1, student2) }

    it "returns a grade for a specific student" do
      grade = create :grade, assignment: assignment, student: student2

      expect(subject.grade(student2)).to eq grade
    end

    it "does not return the grade if the assignment is not the same" do
      grade = create :grade, student: student2

      expect(subject.grade(student2)).to be_nil
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
