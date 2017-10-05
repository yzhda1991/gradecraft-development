describe CSVBadgeImporter do
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

        it "contains an unsuccessful row if the student is not found" do
          result = subject.import(badge)
          expect(result.unsuccessful).to include({ data: ["Kyle", "Dove", "dovek@umich.edu", "1", "Awesome Job!", "1\n"],
            errors: "Active student not found in course" })
        end

        it "timestamps the updated badge" do
          student.reload.update_attribute :email, "seamus.finnigan@hogwarts.edu"
          result = subject.import(badge)
          expect(EarnedBadge.unscoped.last.updated_at).to be_within(1.second).of(DateTime.now)
        end
      end
    end
  end
end
