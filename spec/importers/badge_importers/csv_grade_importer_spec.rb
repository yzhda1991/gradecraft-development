# describe CSVBadgeImporter, focus: true do
describe CSVBadgeImporter, focus: true do
  subject { described_class.new(file.tempfile, professor, course) }

  describe "#import" do
    let(:course) { create :course }
    let(:file) { fixture_file "badges.csv", "text/csv" }
    let(:badge) { create :badge, course: course }
    let!(:professor) { create(:course_membership, :professor, course: course).user }
    let!(:student) { create(:course_membership, :student, course: course, active: true).user }

    it "returns empty results when there is no file" do
      result = described_class.new(nil, nil, nil).import
      expect(result.successful).to be_empty
      expect(result.unsuccessful).to be_empty
    end

    context "when no students exist in the course" do
      it "does not create an earned badge" do
        expect { subject.import(badge) }.to_not change { EarnedBadge.count }
      end

      it "returns unsuccessful rows" do
        result = subject.import(badge)
        expect(result.unsuccessful).to_not be_empty
        expect(result.unsuccessful.pluck(:errors)).to all eq "Active student not found in course"
      end
    end

    context "when the students exist in the course" do
      # let!(:student) { create :user, email: "robert@example.com", courses: [course], role: :student }

      context "with a pass/fail type assignment" do

        it "creates the badge if earned count in csv exceeds earned count in DB" do
          student.reload.update_attribute :email, "seamus.finnigan@hogwarts.edu"
          result = subject.import(badge)
          earned_badge = EarnedBadge.unscoped.last
          expect(earned_badge.badge_id).to eq badge.id
          expect(earned_badge.feedback).to eq "Great Job!"
          expect(earned_badge.student_visible).to be true
          expect(result.successful.count).to eq 2
          expect(result.successful.last).to eq earned_badge
        end

        it "contains an unsuccessful row if the grade is a string" do
          result = subject.import(badge)
          expect(result.unsuccessful).to include({ data: "Kyle,Dove,dovek@umich.edu,1,1,Awesome Job!\n",
            errors: "Active student not found in course" })
        end

end # context
end # context

#
#       it "timestamps the grade" do
#         result = subject.import(course, assignment)
#         expect(Grade.unscoped.last.graded_at).to be_within(1.second).of(DateTime.now)
#       end
#
#       it "does not update the grade if the grade and the feedback are the same as the one being imported" do
#         grade = create :grade, assignment: assignment, student: student, raw_points: 4000, feedback: "You did great!"
#         expect {
#           result = subject.import(course, assignment)
#           expect(result.successful).to be_empty
#           expect(result.unchanged.count).to eq 1
#           expect(result.unchanged.first).to eq grade
#         }.to_not change grade, :updated_at
#       end
#
#       it "does not update the grade if it is already there and the score is null" do
#         student = create(:user, email: "john@example.com", courses: [course], role: :student)
#         grade = create :grade, assignment: assignment, student: student, raw_points: 4000
#         result = subject.import(course, assignment)
#         expect(grade.reload.raw_points).to eq 4000
#         expect(grade.graded_at).to be_nil
#         expect(result.unsuccessful.last[:errors]).to eq "Grade not specified"
#       end
#
#       it "updates the grade if the grade is the same but the feedback is different" do
#         grade = create :grade, assignment: assignment, student: student,
#           raw_points: 4000, feedback: "You need some work"
#         result = subject.import(course, assignment)
#         expect(result.successful.count).to eq 1
#         expect(result.successful.first).to eq grade
#       end
#
#       it "contains an unsuccessful row if the grade is a decimal value" do
#         create :user, email: "kurt.cobain@nirvana.com", courses: [course], role: :student
#         result = subject.import(course, assignment)
#         expect(result.unsuccessful).to_not be_empty
#         expect(result.unsuccessful).to include({ data: "Kurt,Cobain,kurt.cobain@nirvana.com,10.1,\n",
#           errors: "Grade cannot be a decimal value" })
#       end
#
#       it "contains an unsuccessful row if the grade is a string" do
#         create :user, email: "mick.jagger@rollingstones.com", courses: [course], role: :student
#         result = subject.import(course, assignment)
#         expect(result.unsuccessful).to_not be_empty
#         expect(result.unsuccessful).to include({ data: "Mick,Jagger,mick.jagger@rollingstones.com,sheep,...sheep?\n",
#           errors: "Grade is invalid" })
#       end
#
#       it "creates a grade for a student by username" do
#         username_student = create :user, username: "jimmy", courses: [course], role: :student
#         result = subject.import(course, assignment)
#         grade = assignment.grades.where(student_id: username_student.id).first
#         expect(grade).to_not be_nil
#       end
#     end
 end # describe
end
