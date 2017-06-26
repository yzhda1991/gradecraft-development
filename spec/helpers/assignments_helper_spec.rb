describe AssignmentsHelper do
  class Helper
    include AssignmentsHelper
  end

  subject(:helper) { Helper.new }

  describe "#mark_assignment_reviewed!" do
    let(:assignment) { double(:assignment, course: course) }
    let(:course) { double(:course) }
    let(:grade) { double(:grade, new_record?: false) }
    let(:user) { double(:user) }

    it "it marks the grade feedback as reviewed for the current user" do
      allow(user).to receive(:is_student?).with(course).and_return true
      allow(user).to receive(:grade_released_for_assignment?).with(assignment)
        .and_return true
      allow(user).to receive(:grade_for_assignment).with(assignment).and_return grade
      expect(grade).to receive(:feedback_reviewed!)
      helper.mark_assignment_reviewed! assignment, user
    end
  end

  context "course with grade scheme elements" do
    let(:course) { create :course}
    let(:assignment_type) {create :assignment_type, course: course}
    let(:level_index) {1}
    let!(:high) { create(:grade_scheme_element, lowest_points: 2001, letter: "A", course: course) }
    let!(:low) { create(:grade_scheme_element, lowest_points: 100, letter: "C", course: course) }
    let!(:middle) { create(:grade_scheme_element, lowest_points: 1001, letter: "B", course: course) }

    before(:each) do
     allow(helper).to receive(:current_course).and_return course
     allow(course).to receive(:total_points).and_return 5000
    end

    describe "#total_available_points" do
       it "returns total number if grading scheme exists" do
         total_available_points = helper.total_available_points
         expect(total_available_points).to eq(2001)
       end
     end

    describe "#percent_of_total_points" do
      it "returns grade scheme element's ratio of total points" do
       percent_of_total_points = helper.percent_of_total_points(level_index)
       expect(percent_of_total_points).to eq(45.48)
      end
    end

    describe "level_letter_grade" do
      it "returns letter of selected grade scheme element" do
        level_letter_grade = helper.level_letter_grade(level_index)
        expect(level_letter_grade).to eq("B")
      end
    end

    describe "level_point_threshold" do
      it "returns point threshold of selected grade scheme element" do
        level_point_threshold = helper.level_point_threshold(level_index)
        expect(level_point_threshold).to eq(1001)
      end
    end
  end

  context "course without grade scheme elements" do
    let(:course) { create :course}
    let(:assignment_type) {create :assignment_type, course: course}

    before(:each) do
     allow(helper).to receive(:current_course).and_return course
     allow(course).to receive(:total_points).and_return 5000
    end

    describe "#total_available_points" do
      it "returns total_points if no grading scheme exists" do
        total_available_points = helper.total_available_points
        expect(total_available_points).to eq(5000)
      end
    end
  end
end
