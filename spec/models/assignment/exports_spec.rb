RSpec.describe "Assignment grade export methods" do
  let(:assignment) { build(:assignment, course: course) }
  let(:students) { build_list(:user, 2) }
  let(:course) { build(:course) }

  describe "#grade_import" do
    subject { assignment.grade_import(students, options) }

    let(:options) {{ encoding: "UTF-8" }}
    let(:grade_exporter) { double(GradeExporter) }
    before do
      allow(GradeExporter).to receive(:new) { grade_exporter }
      allow(grade_exporter).to receive(:export_grades)
    end

    it "builds a new GradeExporter" do
      expect(GradeExporter).to receive(:new)
      subject
    end

    it "exports the grades with GradeExporter" do
      expect(grade_exporter).to receive(:export_grades).with(assignment, students, options)
      subject
    end
  end
end
