describe Services::CreatesManyGrades do
  let(:student) { create(:user) }
  let(:assignment) { create(:assignment) }
  let(:graded_by_id) { 1 }
  let(:grade_attributes) { { "0" => { instructor_modified: true, student_id: student.id,
      raw_points: 1000, student_visible: true } } }

  describe ".call" do
    it "iterates grade attributes" do
      expect(Services::Actions::IteratesGradeAttributes).to receive(:execute).and_call_original
      described_class.call assignment.id, graded_by_id, grade_attributes
    end
  end
end
