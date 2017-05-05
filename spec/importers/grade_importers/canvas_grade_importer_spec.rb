describe CanvasGradeImporter do
  describe "#import" do
    it "returns empty results if there are no canvas grades" do
      result = described_class.new(nil).import(nil, nil)

      expect(result.successful).to be_empty
      expect(result.unsuccessful).to be_empty
    end

    context "with some canvas grades" do
      let(:assignment) { create :assignment }
      let(:canvas_grade) do
        {
          id: canvas_grade_id,
          score: 98.0,
          user_id: "USER_1",
          submission_comments: [{"comment" => "This is great!"}]
        }.stringify_keys
      end
      let(:canvas_user) do
        {
          primary_email: user.email
        }.stringify_keys
      end
      let(:canvas_grade_id) { "GRADE_1" }
      let(:grade) { Grade.unscoped.last }
      let(:syllabus) { double(:syllabus, user: canvas_user) }
      let(:user) { create :user }
      subject { described_class.new([canvas_grade]) }

      it "creates the grade" do
        expect { subject.import(assignment.id, syllabus) }.to \
          change { Grade.count }.by 1
        expect(grade.assignment).to eq assignment
        expect(grade.student).to eq user
        expect(grade.raw_points).to eq 98
        expect(grade.feedback).to eq "Comment 1: This is great!"
        expect(grade.status).to eq "Graded"
        expect(grade).to be_instructor_modified
      end

      it "creates a link to the grade id in canvas" do
        subject.import(assignment.id, syllabus)

        imported_grade = ImportedGrade.unscoped.last
        expect(imported_grade.grade).to eq grade
        expect(imported_grade.provider).to eq "canvas"
        expect(imported_grade.provider_resource_id).to eq canvas_grade_id
      end

      it "contains a successful row if the grade is valid" do
        result = subject.import(assignment.id, syllabus)

        expect(result.successful.count).to eq 1
        expect(result.successful.last).to eq grade
      end

      it "contains an unsuccessful row if the grade is not valid" do
        allow_any_instance_of(Grade).to receive(:save).and_return false
        allow_any_instance_of(Grade).to receive(:errors)
          .and_return(double(:errors, full_messages: ["Something is wrong"]))

        result = subject.import(assignment.id, syllabus)

        expect(result.unsuccessful.count).to eq 1
        expect(result.unsuccessful.first[:errors]).to eq "Something is wrong"
      end

      context "with an existing grade for the assignment and student" do
        let!(:existing_grade) { create :grade,
                                assignment_id: assignment.id, student_id: user.id,
                                raw_points: 76, feedback: "You rock!" }

        context "with override" do
          it "replaces the grade score and comments" do
            result = subject.import(assignment.id, syllabus, true)

            expect(result.successful.count).to eq 1
            expect(result.unsuccessful.count).to eq 0
            expect(grade.assignment).to eq assignment
            expect(grade.student).to eq user
            expect(grade.raw_points).to eq 98
            expect(grade.feedback).to eq "Comment 1: This is great!"
          end
        end

        context "without an override" do
          it "contains an unsuccessful row" do
            result = subject.import(assignment.id, syllabus)

            expect(result.successful.count).to eq 0
            expect(result.unsuccessful.count).to eq 1
          end
        end
      end
    end
  end
end
