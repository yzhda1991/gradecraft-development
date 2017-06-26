describe Badge do
  subject { create(:badge) }
  let(:student) { build_stubbed(:user) }
  let(:assignment) { create(:assignment) }

  context "validations" do
    it "is valid with a name and a course" do
      expect(subject).to be_valid
    end

    it "is invalid without a name" do
      subject.name = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:name]).to include "can't be blank"
    end

    it "is invalid without course" do
      subject.course = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:course]).to include "can't be blank"
    end

    it "is invalid without a visible state" do
      subject.visible = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:visible]).to include "must be true or false"
    end

    it "is invalid without a can_earn_multiple_times state" do
      subject.can_earn_multiple_times = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:can_earn_multiple_times]).to include "must be true or false"
    end

    it "is invalid without a visible_when_locked state" do
      subject.visible_when_locked = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:visible_when_locked]).to include "must be true or false"
    end

    it "is invalid without a show_name_when_locked state" do
      subject.show_name_when_locked = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:show_name_when_locked]).to include "must be true or false"
    end

    it "is invalid without a show_points_when_locked state" do
      subject.show_points_when_locked = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:show_points_when_locked]).to include "must be true or false"
    end

    it "is invalid without a show_description_when_locked state" do
      subject.show_description_when_locked = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:show_description_when_locked]).to include "must be true or false"
    end
  end

  describe "#can_earn_multiple_times" do
    it "is possible by default to earn a badge more than once in a course" do
      expect(subject.can_earn_multiple_times).to eq(true)
    end

    it "if so set, it is not possible to earn the badge more than once in a course" do
      subject.can_earn_multiple_times = false
      expect(subject.can_earn_multiple_times).to eq(false)
    end
  end

  describe "#copy" do
    let(:badge) { build :badge }
    subject { badge.copy }

    it "makes a duplicated copy of itself" do
      expect(subject).to_not eq badge
    end
  end

  describe "#earned_badge_count_for_student(student)" do
    it "sums up the number of times a student has earned a specific badge" do
      second_badge = create(:badge)
      earned_badge = create(:earned_badge, badge: subject, student: student)
      second_earned_badge = create(:earned_badge, badge: subject, student: student)
      third_earned_badge = create(:earned_badge, badge: second_badge, student: student)
      expect(subject.earned_badge_count_for_student(student)).to eq(2)
    end
  end
end
