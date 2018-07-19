RSpec.shared_examples "a submission email to a professor" do
  it "includes the student's first name" do
    should include_in_mail_body student.first_name
  end

  it "includes the student's last name" do
    should include_in_mail_body student.last_name
  end

  it "includes the professor's first name" do
    should include_in_mail_body professor.first_name
  end

  it "includes the assignment name" do
    should include_in_mail_body assignment.name
  end

  it "includes the assignment term for the course" do
    should include_in_mail_body course.assignment_term.downcase
  end

  it "includes the course name" do
    should include_in_mail_body course.name
  end

  it "doesn't include a template" do
    should_not include "Regents of The University of Michigan"
    should_not include "DOCTYPE"
  end
end

# specs for submission notifications that are sent to students
describe NotificationMailer do
  extend Toolkits::Mailers::EmailToolkit::Definitions # brings in helpers for default emails and parts
  define_email_context # taken from the definitions toolkit

  include Toolkits::Mailers::EmailToolkit::SharedExamples # brings in shared examples for emails and parts

  let(:submission) { create(:submission, course: course, student: student, assignment: assignment) }
  let(:student) { create(:user) }
  let(:professor) { create(:user) }
  let(:course) { create(:course, assignment_term: "whifflebox") }
  let(:assignment) { create(:assignment) }

  describe "#new_submission" do
    before(:each) do
      NotificationMailer.new_submission(submission.id, professor).deliver_now
    end

    it "is sent from gradecraft's default mailer email" do
      expect(email.from).to eq [sender]
    end

    it "is sent to the professor's email" do
      expect(email.to).to eq [professor.email]
    end

    it "has the correct subject" do
      expect(email.subject).to eq "#{course.course_number} - #{assignment.name} - New Submission to Grade"
    end

    describe "text email body" do
      subject { text_part.body }
      it_behaves_like "a submission email to a professor"
    end
  end

  describe "#revised_submission" do
    before(:each) do
      NotificationMailer.revised_submission(submission.id, professor).deliver_now
    end

    it "is sent from gradecraft's default mailer email" do
      expect(email.from).to eq [sender]
    end

    it "is sent to the professor's email" do
      expect(email.to).to eq [professor.email]
    end

    it "has the correct subject" do
      expect(email.subject).to eq "#{course.course_number} - #{assignment.name} - Updated Submission to Grade"
    end

    describe "text email body" do
      subject { text_part.body }
      it_behaves_like "a submission email to a professor"
    end
  end
end
