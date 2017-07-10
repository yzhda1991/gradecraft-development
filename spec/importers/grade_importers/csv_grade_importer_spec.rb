describe CSVGradeImporter do
  subject { described_class.new(file.tempfile) }

  describe "#import" do
    let(:course) { create :course }
    let(:file) { fixture_file "grades.csv", "text/csv" }
    let(:assignment) { create :assignment, course: course }

    it "returns empty results when there is no file" do
      result = described_class.new(nil).import
      expect(result.successful).to be_empty
      expect(result.unsuccessful).to be_empty
    end

    context "when no students exist in the course" do
      it "does not create a grade" do
        expect { subject.import(course, assignment) }.to_not change { Grade.count }
      end

      it "returns unsuccessful rows" do
        result = subject.import(course, assignment)
        expect(result.unsuccessful).to_not be_empty
        expect(result.unsuccessful.pluck(:errors)).to all eq "Student not found in course"
      end
    end

    context "when the students exist in the course" do
      let!(:student) { create :user, email: "robert@example.com", courses: [course], role: :student }

      context "with a pass/fail type assignment" do
        let(:assignment) { create :assignment, :pass_fail, course: course }
        let(:file) { fixture_file "pass_fail_grades.csv", "text/csv" }

        it "creates the grade if one did not previously exist" do
          result = subject.import(course, assignment)
          grade = Grade.unscoped.last
          expect(grade.raw_points).to eq 0
          expect(grade.pass_fail_status).to eq "Pass"
          expect(grade.feedback).to eq "Rock on!"
          expect(grade.status).to eq "Graded"
          expect(grade.instructor_modified).to eq true
          expect(result.successful.count).to eq 1
          expect(result.successful.last).to eq grade
        end

        it "contains an unsuccessful row if the grade is not 0 or 1" do
          create :user, email: "don.henley@eagles.com", courses: [course], role: :student
          result = subject.import(course, assignment)
          expect(result.unsuccessful).to include({ data: "Don,Henley,don.henley@eagles.com,2,\n",
            errors: "Grade must be 0 (false) or 1 (true)"})
        end

        it "contains an unsuccessful row if the grade is a string" do
          create :user, email: "steve.perry@journey.com", courses: [course], role: :student
          result = subject.import(course, assignment)
          expect(result.unsuccessful).to include({ data: "Steve,Perry,steve.perry@journey.com,pass,\n",
            errors: "Grade is invalid" })
        end

        it "updates the grade if one previously existed" do
          grade = create :grade, assignment: assignment, student: student, pass_fail_status: "Fail"
          subject.import(course, assignment)
          grade.reload
          expect(grade.raw_points).to eq 0
          expect(grade.pass_fail_status).to eq "Pass"
          expect(grade.feedback).to eq "Rock on!"
          expect(grade.graded_at).to_not be_nil
        end
      end

      context "with a non pass/fail type assignment" do
        it "creates the grade if one did not previously exist" do
          result = subject.import(course, assignment)
          grade = Grade.unscoped.last
          expect(grade.raw_points).to eq 4000
          expect(grade.feedback).to eq "You did great!"
          expect(grade.status).to eq "Graded"
          expect(grade.instructor_modified).to eq true
          expect(result.successful.count).to eq 1
          expect(result.successful.last).to eq grade
        end

        it "updates the grade if one previously existed" do
          create :grade, assignment: assignment, student: student, raw_points: 1000
          subject.import(course, assignment)
          grade = Grade.last
          expect(grade.raw_points).to eq 4000
          expect(grade.feedback).to eq "You did great!"
          expect(grade.graded_at).to_not be_nil
        end
      end

      it "timestamps the grade" do
        result = subject.import(course, assignment)
        expect(Grade.unscoped.last.graded_at).to be_within(1.second).of(DateTime.now)
      end

      it "does not update the grade if the grade and the feedback are the same as the one being imported" do
        grade = create :grade, assignment: assignment, student: student, raw_points: 4000, feedback: "You did great!"
        expect {
          result = subject.import(course, assignment)
          expect(result.successful).to be_empty
          expect(result.unchanged.count).to eq 1
          expect(result.unchanged.first).to eq grade
        }.to_not change grade, :updated_at
      end

      it "does not update the grade if it is already there and the score is null" do
        student = create(:user, email: "john@example.com", courses: [course], role: :student)
        grade = create :grade, assignment: assignment, student: student, raw_points: 4000
        result = subject.import(course, assignment)
        expect(grade.reload.raw_points).to eq 4000
        expect(grade.graded_at).to be_nil
        expect(result.unsuccessful.last[:errors]).to eq "Grade not specified"
      end

      it "updates the grade if the grade is the same but the feedback is different" do
        grade = create :grade, assignment: assignment, student: student,
          raw_points: 4000, feedback: "You need some work"
        result = subject.import(course, assignment)
        expect(result.successful.count).to eq 1
        expect(result.successful.first).to eq grade
      end

      it "contains an unsuccessful row if the grade is a decimal value" do
        create :user, email: "kurt.cobain@nirvana.com", courses: [course], role: :student
        result = subject.import(course, assignment)
        expect(result.unsuccessful).to_not be_empty
        expect(result.unsuccessful).to include({ data: "Kurt,Cobain,kurt.cobain@nirvana.com,10.1,\n",
          errors: "Grade cannot be a decimal value" })
      end

      it "contains an unsuccessful row if the grade is a string" do
        create :user, email: "mick.jagger@rollingstones.com", courses: [course], role: :student
        result = subject.import(course, assignment)
        expect(result.unsuccessful).to_not be_empty
        expect(result.unsuccessful).to include({ data: "Mick,Jagger,mick.jagger@rollingstones.com,sheep,...sheep?\n",
          errors: "Grade is invalid" })
      end

      it "creates a grade for a student by username" do
        username_student = create :user, username: "jimmy", courses: [course], role: :student
        result = subject.import(course, assignment)
        grade = assignment.grades.where(student_id: username_student.id).first
        expect(grade).to_not be_nil
      end
    end
  end
end
