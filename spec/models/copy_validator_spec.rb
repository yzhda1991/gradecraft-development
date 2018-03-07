describe CopyValidator do
  subject { described_class.new }

  let(:course) { create :course }
  let!(:assignment_type) { create :assignment_type, course: course }
  let!(:assignments) { create_list :assignment, 2, course: course, assignment_type: assignment_type }
  let!(:grade_scheme_elements) { create_list :grade_scheme_element, 3, course: course }

  describe "#validate" do
    it "checks validation against all associated models" do
      result = subject.validate course

      expect(result.has_errors).to eq false
      expect(result.details[:courses].length).to eq 1
      expect(result.details[:assignment_types].length).to eq 1
      expect(result.details[:assignments].length).to eq 2
      expect(result.details[:grade_scheme_elements].length).to eq 3
    end

    it "checks validation on any additional associations" do
      assignment = assignments.first
      assignment.update_columns max_group_size: -1
      create :rubric_with_criteria, assignment: assignment, course: course

      result = subject.validate assignment, lookup_key: :assignments, associations: [:rubric]

      expect(result.has_errors).to eq true
      expect(result.details[:assignments].length).to eq 1
      expect(result.details[:rubrics].length).to eq 1
      expect(result.details[:criteria].length).to eq assignment.rubric.criteria.length
      expect(result.details[:levels].length).to eq assignment.rubric.criteria.sum(&:levels).length
    end

    it "returns information regarding whether a model is valid or not" do
      assignment_type.update_columns max_points: -1
      assignment_type.valid?
      result = subject.validate course

      expect(result.has_errors).to eq true
      expect(result.details[:assignment_types]).to include type: :assignment_type,
        id: assignment_type.id, valid: false, errors: assignment_type.reload.errors.full_messages
    end
  end
end

describe CopyValidatorResult do
  describe "#to_h" do
    subject { described_class.new :course, 1, false, errors.full_messages }

    let(:errors) { double(full_messages: ["Course is fake!"]) }

    it "returns a hash for the provided attributes" do
      expect(subject.to_h).to be_a Hash
      expect(subject.to_h).to include type: :course, id: 1, valid: false, errors: errors.full_messages
    end
  end
end
