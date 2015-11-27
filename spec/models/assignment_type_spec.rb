require "active_record_spec_helper"

describe AssignmentType do
  let!(:world) do
    World.create
      .create_course
      .create_student
      .create_assignment
      .create_grade
  end

  describe "validations" do
    subject { build(:assignment_type) }

    it "is valid with a name" do
      expect(subject).to be_valid
    end

    it "is invalid without a name" do
      subject.name = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:name]).to include "can't be blank"
    end

    it "is only valid with positive max points" do 
      subject.max_points = -1000
      expect(subject).to be_invalid
    end
  end

  describe "#weight_for_student(student)" do 

    let(:assignment_type) {create :assignment_type }
    let(:student) { create :user }

    it "returns 1 unless the assignment is student weightable" do 
      expect(assignment_type.weight_for_student(student))
    end

    it "returns a weight if a student has assigned it" do 
      assignment_type.student_weightable = true
      assignment = create(:assignment, assignment_type: assignment_type, course: world.course)
      create(:assignment_weight, student: student, course: world.course, assignment: assignment, weight: 3)
      
      expect(assignment_type.weight_for_student(student)).to eq(3)
    end
  end

  describe "#is_capped?" do 
    let(:assignment_type) {create :assignment_type}

    it 'returns false if the assignment type has no max value' do 
      expect(assignment_type.is_capped?).to eq(false)
    end

    it 'returns true if the assignment type has a max value' do 
      assignment_type.max_points = 10000
      expect(assignment_type.is_capped?).to eq(true)
    end
  end

  describe "#total_points" do 
    let(:assignment_type) {create :assignment_type}

    it 'returns true if the assignment type has max points' do 
      assignment_type.max_points = 10000
      expect(assignment_type.total_points).to eq(10000)
    end

    it 'returns the sum of the assignments in the assignment type if it does not have max points' do 
      create(:assignment, assignment_type: assignment_type, point_total: 100)
      expect(assignment_type.total_points).to eq(100)
    end
  end

  describe "#total_points_for_student(student)" do 
    let(:assignment_type) {create :assignment_type, course: world.course}
    let(:student) {create :user}

    it 'returns the max points if they are present' do 
      assignment_type.max_points = 10000
      expect(assignment_type.total_points_for_student(student)).to eq(10000)
    end

    it "returns the weighted total for the student" do
      assignment_type.student_weightable = true
      assignment = create(:assignment, assignment_type: assignment_type, course: world.course, point_total: 100)
      create(:assignment_weight, student: student, course: world.course, assignment: assignment, weight: 3)
      
      expect(assignment_type.total_points_for_student(student)).to eq(300)
    end

    it "returns the total number of points if it's not weightable and there's no cap" do 
      assignment = create(:assignment, assignment_type: assignment_type, course: world.course, point_total: 100)
      expect(assignment_type.total_points_for_student(student)).to eq(100)
    end
  end

  describe "#summed_assignment_points" do 
    let(:assignment_type) {create :assignment_type, course: world.course}
    
    it 'returns the sum of the assignments in the assignment type if it does not have max points' do 
      create(:assignment, assignment_type: assignment_type, point_total: 100)
      create(:assignment, assignment_type: assignment_type, point_total: 100)
      create(:assignment, assignment_type: assignment_type, point_total: 100)
      expect(assignment_type.summed_assignment_points).to eq(300)
    end
  end

  describe "#weighted_total_for_student(student)" do 
    let(:assignment_type) {create :assignment_type, course: world.course}
    let(:student) {create :user}

    it "returns the weighted total if the student has assigned weight to it" do
      assignment_type.student_weightable = true
      assignment = create(:assignment, assignment_type: assignment_type, course: world.course, point_total: 100)
      create(:assignment_weight, student: student, course: world.course, assignment: assignment, weight: 3)
      
      expect(assignment_type.weighted_total_for_student(student)).to eq(300)
    end

    it "returns the weighted total if the student has *not* assigned weight to it (point total * default weight)" do 
      world.course.default_assignment_weight = 0.5
      assignment_type.student_weightable = true
      assignment = create(:assignment, assignment_type: assignment_type, course: world.course, point_total: 100)
      
      expect(assignment_type.weighted_total_for_student(student)).to eq(50)
    end
  end

  describe "#visible_score_for_student(student)" do 
    let(:assignment_type) {create :assignment_type, course: world.course}
    let(:student) {create :user}

    it 'returns the max point value for the type if present and the student has earned MORE than that cap' do 
      assignment_type.max_points = 100
      assignment = create(:assignment, course: world.course, assignment_type: assignment_type, release_necessary: true)
      grade = create(:grade, student: student, raw_score: 200, assignment: assignment, status: "Released")
      expect(assignment_type.visible_score_for_student(student)).to eq(100)
    end

    it 'returns the student score if the max point total is present but they have earned less than that value' do 
      assignment_type.max_points = 500
      assignment = create(:assignment, course: world.course, assignment_type: assignment_type, release_necessary: true)
      grade = create(:grade, student: student, raw_score: 200, assignment: assignment, status: "Released")
      expect(assignment_type.visible_score_for_student(student)).to eq(200)
    end

    it 'returns the student score if there is no total present' do 
      assignment = create(:assignment, course: world.course, assignment_type: assignment_type, release_necessary: true)
      grade = create(:grade, student: student, raw_score: 1000, assignment: assignment, status: "Released")
      expect(assignment_type.visible_score_for_student(student)).to eq(1000)
    end

    it 'does not include unreleased grades' do 
      assignment = create(:assignment, course: world.course, assignment_type: assignment_type, release_necessary: true)
      grade = create(:grade, student: student, raw_score: 1000, assignment: assignment, status: "Graded")
      expect(assignment_type.visible_score_for_student(student)).to eq(0)
    end

  end

  describe "#score_for_student(student)" do 
    let(:assignment_type) {create :assignment_type, course: world.course}
    let(:student) {create :user}

    it "returns the total score a student has earned for an assignment type" do 
      assignment = create(:assignment, course: world.course, assignment_type: assignment_type, release_necessary: true)
      assignment_2 = create(:assignment, course: world.course, assignment_type: assignment_type, release_necessary: true)
      grade = create(:grade, student: student, raw_score: 100, assignment: assignment, status: "Released")
      grade = create(:grade, student: student, raw_score: 100, assignment: assignment_2, status: "Released")
      expect(assignment_type.score_for_student(student)).to eq(200)
    end

    it "returns the total score a student has earned for an assignment type and has a reduced final score" do 
      assignment = create(:assignment, course: world.course, assignment_type: assignment_type, release_necessary: true)
      grade = create(:grade, student: student, raw_score: 100, final_score: 75, assignment: assignment, status: "Released")
      expect(assignment_type.score_for_student(student)).to eq(75)
    end

    it "does not include unreleased grades in the score" do 
      assignment = create(:assignment, course: world.course, assignment_type: assignment_type, release_necessary: true)
      grade = create(:grade, student: student, raw_score: 100, assignment: assignment, status: "Graded")
      expect(assignment_type.score_for_student(student)).to eq(0)
    end

    it "does return a weighted score if present"   do 
      assignment_type.student_weightable = true
      assignment = create(:assignment, course: world.course, assignment_type: assignment_type, release_necessary: true)
      create(:assignment_weight, student: student, course: world.course, assignment: assignment, weight: 3)
      grade = create(:grade, student: student, raw_score: 100, assignment: assignment, status: "Released")
      
      expect(assignment_type.score_for_student(student)).to eq(300)
    end
  end

  describe "#raw_score_for_student(student)" do 
    let(:assignment_type) {create :assignment_type, course: world.course}
    let(:student) {create :user}
    
    it "returns the raw score if present"  do 
      assignment_type.student_weightable = true
      assignment = create(:assignment, course: world.course, assignment_type: assignment_type, release_necessary: true)
      create(:assignment_weight, student: student, course: world.course, assignment: assignment, weight: 3)
      grade = create(:grade, student: student, raw_score: 100, assignment: assignment, status: "Released")
      expect(assignment_type.raw_score_for_student(student)).to eq(100)
    end

    it "does not include unreleased grades" do 
      assignment = create(:assignment, course: world.course, assignment_type: assignment_type, release_necessary: true)
      create(:assignment_weight, student: student, course: world.course, assignment: assignment, weight: 3)
      grade = create(:grade, student: student, raw_score: 100, assignment: assignment, status: "Graded")
      expect(assignment_type.raw_score_for_student(student)).to eq(0)
    end
  end
  
end
