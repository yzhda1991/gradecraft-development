require "active_record_spec_helper"

describe Group do
  let!(:course) { create :course, max_group_size: 4 }
  subject { create(:group, course: course ) }

  describe "validations" do
    it "is valid with a name and an approval state" do
      expect(subject).to be_valid
    end

    it "is invalid without a name" do
      subject.name = nil
      expect(subject).to be_invalid
    end

    it "is invalid without an approval state" do
      subject.approved = nil
      expect(subject).to be_invalid
    end

    it "does not allow more group members than the course max" do
      group_assignment = create(:assignment, grade_scope: "Group", course: course)
      new_group = Group.create course_id: course.id, name: "Group Name", approved: "Pending"
      group_membership = create(:group_membership, group: new_group)
      group_membership_2 = create(:group_membership, group: new_group)
      group_membership_3 = create(:group_membership, group: new_group)
      group_membership_4 = create(:group_membership, group: new_group)
      group_membership_5 = create(:group_membership, group: new_group)
      expect(new_group.students.count).to eq 5
      expect(new_group).to_not be_valid
      expect(new_group.errors[:base]).to include "You have too many group members."
    end

    it "does not allow fewer group members than the course min" do
    end

    it "does not allow students to belong to more than one group per assignment" do

    end

    it "requires the group to work on at least one assignment" do

    end
  end


end
