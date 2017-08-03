describe BadgeExporter do
  let(:badge) { create :badge }
  let(:course) { create :course }
  let!(:student1) { create(:course_membership, :student, course: course, active: true).user }
  let!(:student2) { create(:course_membership, :student, course: course, active: true).user }
  subject { BadgeExporter.new }

  describe "#export_badges" do
    it "generates an empty CSV if there is no badge specified" do
      csv = subject.export_badges(nil, course)
      expect(csv).to eq "First Name,Last Name,Email,Has,Earned,Feedback (optional)\n"
    end

    it "generates an empty CSV if there is no course specified" do
      csv = subject.export_badges(badge, nil)
      expect(csv).to eq "First Name,Last Name,Email,Has,Earned,Feedback (optional)\n"
    end

    it "generates a CSV with grade statuses if the assignment is pass/fail and we
        want statuses as plaintext" do
      csv = CSV.new(subject.export_badges(badge, course)).read
      expect(csv.length).to eq 3
      expect(csv[1][0]).to eq student1.first_name
      expect(csv[1][1]).to eq student1.last_name
      expect(csv[1][2]).to eq student1.email
      expect(csv[1][3]).to eq course.earned_badges.where(student_id: student1.id, badge_id: badge.id).count.to_s
      expect(csv[1][4]).to eq "1"
      expect(csv[1][5]).to eq "Awesome Job!"
    end
  end
end
