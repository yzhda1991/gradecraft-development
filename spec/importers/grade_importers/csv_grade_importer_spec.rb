describe CSVGradeImporter do
  subject { described_class.new(file.tempfile) }

  describe "#import" do
    let(:course) { create :course }

    it "returns empty results when there is no file" do
      result = described_class.new(nil).import
      expect(result.successful).to be_empty
      expect(result.unsuccessful).to be_empty
    end

    context "with a file" do
      let(:file) { fixture_file "grades.csv", "text/csv" }
      let(:assignment) { create :assignment, course: course }

      context "with a student not in the file" do
        let!(:student) { create :user, courses: [course], role: :student }

        it "does not create a grade if the student does not exist" do
          expect { subject.import(course, assignment) }.to_not change { User.count }
        end

        it "is unsuccessful if the student does not exist" do
          result = subject.import(course, assignment)
          expect(result.unsuccessful.count).to eq 4
          expect(result.unsuccessful.first[:errors]).to eq "Student not found in course"
        end
      end

      context "with a student in the file" do
        let!(:student) { create :user, email: "robert@example.com", courses: [course], role: :student }
        let(:another_student) { create :user, email: "eric.clapton@guitarlegends.com", courses: [course], role: :student}

        context "when the assignment is of pass/fail type" do
          let(:assignment) { create :assignment, course: course, pass_fail: true }
          let(:file) { fixture_file "pass_fail_grades.csv", "text/csv" }

          it "creates the grade if it is not there" do
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

          it "contains an unsuccessful row if the grade is not valid" do
            create :user, email: "don.henley@eagles.com", courses: [course], role: :student
            result = subject.import(course, assignment)
            expect(result.unsuccessful.count).to be >= 1
            expect(result.unsuccessful.pluck(:errors)).to include "Grade is invalid"
          end

          it "contains an unsuccessful row if the grade is not valid" do
            create :user, email: "steve.perry@journey.com", courses: [course], role: :student
            result = subject.import(course, assignment)
            expect(result.unsuccessful.count).to be >= 1
            expect(result.unsuccessful.pluck(:errors)).to include "Grade is invalid"
          end

          it "updates the grade to pass if the grade previously existed" do
            grade = create :grade, assignment: assignment, student: student, pass_fail_status: "Fail"
            subject.import(course, assignment)
            grade.reload
            expect(grade.raw_points).to eq 0
            expect(grade.pass_fail_status).to eq "Pass"
            expect(grade.feedback).to eq "Rock on!"
            expect(grade.graded_at).to_not be_nil
          end

          it "updates the grade to fail if the grade previously existed" do
            grade = create :grade, assignment: assignment, student: another_student, pass_fail_status: "Pass"
            subject.import(course, assignment)
            grade.reload
            expect(grade.raw_points).to eq 0
            expect(grade.pass_fail_status).to eq "Fail"
            expect(grade.feedback).to be_empty
            expect(grade.graded_at).to_not be_nil
          end
        end

        context "when the assignment is not pass/fail type" do
          it "creates the grade if it is not there" do
            result = subject.import(course, assignment)
            grade = Grade.unscoped.last
            expect(grade.raw_points).to eq 4000
            expect(grade.feedback).to eq "You did great!"
            expect(grade.status).to eq "Graded"
            expect(grade.instructor_modified).to eq true
            expect(result.successful.count).to eq 1
            expect(result.successful.last).to eq grade
          end

          it "updates the grade if it is already there" do
            create :grade, assignment: assignment, student: student, raw_points: 1000
            subject.import(course, assignment)
            grade = Grade.last
            expect(grade.raw_points).to eq 4000
            expect(grade.feedback).to eq "You did great!"
            expect(grade.graded_at).to_not be_nil
          end
        end

        it "timestamps the grade" do
          current_time = DateTime.now
          result = subject.import(course, assignment)
          grade = Grade.unscoped.last
          expect(grade.graded_at).to be > current_time
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
          student = create(:user, email: "john@example.com")
          grade = create :grade, assignment: assignment, student: student, raw_points: 4000
          create(:course_membership, :student, course: course, user: student)
          result = subject.import(course, assignment)
          expect(grade.reload.raw_points).to eq 4000
          expect(grade.graded_at).to be_nil
          expect(result.unsuccessful.last[:errors]).to eq "Grade not specified"
        end

        it "updates the grade if the grade is the same but the feedback is different" do
          grade = create :grade, assignment: assignment, student: student, raw_points: 4000, feedback: "You need some work"
          result = subject.import(course, assignment)
          expect(result.successful.count).to eq 1
          expect(result.successful.first).to eq grade
        end

        it "contains an unsuccessful row if the grade is not valid" do
          allow_any_instance_of(Grade).to receive(:valid?).and_return false
          allow_any_instance_of(Grade).to receive(:errors).and_return double(full_messages: ["The grade is not cool"])
          result = subject.import(course, assignment)
          expect(result.unsuccessful.count).to eq 4
          expect(result.unsuccessful.first[:errors]).to eq "The grade is not cool"
        end

        it "creates a grade for a student by username" do
          username_student = create :user, username: "jimmy"
          create :course_membership, :student, user_id: username_student.id, course_id: course.id
          result = subject.import(course, assignment)
          grade = assignment.grades.where(student_id: username_student.id).first
          expect(grade).to_not be_nil
        end
      end
    end
  end
end
