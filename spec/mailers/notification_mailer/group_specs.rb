require 'rails_spec_helper'

RSpec.shared_examples "a group email sent to several students" do |email, student|
  it "is sent from gradecraft's default mailer email" do
    expect(email.from).to eq [sender]
  end

  it "is sent to the second student's email" do
    expect(email.to).to eq [student.email]
  end

  it "has the correct subject" do
    expect(email.subject).to eq "#{course.courseno} - New Group"
  end

  describe "text email part body" do
    subject { email.body }

    it "doesn't include a template" do
      should_not include "Regents of The University of Michigan"
    end
  end
end

# specs for submission notifications that are sent to students
describe NotificationMailer do
  let(:sender) { NotificationMailer::SENDER_EMAIL }
  let(:professor) { create(:user) }
  let(:group) { create(:group, course: course) }
  let(:course) { create(:course) }

  describe "#group_created" do
    let(:email) { ActionMailer::Base.deliveries.last }

    before(:each) do
      NotificationMailer.group_created(group.id, professor).deliver_now
    end

    it "is sent from gradecraft's default mailer email" do
      expect(email.from).to eq [sender]
    end

    it "is sent to the professor's email" do
      expect(email.to).to eq [professor.email]
    end

    it "has the correct subject" do
      expect(email.subject).to eq "#{course.courseno} - New Group to Review"
    end

    describe "text email part body" do
      subject { email.body }

      it "includes the professor's last name" do
        should include professor.last_name
      end

      it "doesn't include a template" do
        should_not include "Regents of The University of Michigan"
      end

      it "includes the course name" do
        should include course.name
      end
    end
  end

  describe "#group_notify", focus: true do
    before(:all) do
      @course = create(:course, max_group_size: 40)

      # create some students
      @student1 = create(:user)
      @student2 = create(:user)
      @student3 = create(:user)

      # create a group for the students
      @group = create(:group, course: @course, course_id: @course.id, students: [ @student1, @student2, @student3 ])

    end

    before(:each) do
      # send an email to that whole group
      NotificationMailer.group_notify(@group.id).deliver_now

      # grab the emails for that message
      @email1 = ActionMailer::Base.deliveries.last
      @email2 = ActionMailer::Base.deliveries.last
      @email3 = ActionMailer::Base.deliveries.last
    end

    it_behaves_like "a group email sent to several students", @email1, @student1
    it_behaves_like "a group email sent to several students", @email2, @student2
    it_behaves_like "a group email sent to several students", @email3, @student3
  end
end
