require 'rails_spec_helper'

RSpec.shared_examples "a complete email body" do 
  it "includes the student's first name" do
    should include student.first_name
  end

  it "includes the assignment name" do
    should include assignment.name
  end

  it "includes the assignment term for the course" do
    should include course.assignment_term.pluralize.downcase
  end

  it "includes the course name" do
    should include course.name
  end

  it "includes the submission created_at timestamp" do
    should include submission.created_at
  end
end

describe NotificationMailer do
  let(:email) { ActionMailer::Base.deliveries.last }
  let(:sender) { NotificationMailer::SENDER_EMAIL }
  let(:admin_email) { NotificationMailer::ADMIN_EMAIL }
  let(:text_part) { email.body.parts.detect {|part| part.content_type.match "text/plain" }}
  let(:html_part) { email.body.parts.detect {|part| part.content_type.match "text/html" }}

  describe "#successful_submission" do
    let(:submission) { create(:submission, course: course, student: student, assignment: assignment) }
    let(:student) { create(:user) }
    let(:course) { create(:course, assignment_term: "whifflebox") }
    let(:assignment) { create(:assignment) }

    before(:each) do
      NotificationMailer.successful_submission(submission.id).deliver_now
    end

    it "is sent from gradecraft's default mailer email" do
      expect(email.from).to eq [sender]
    end

    it "is sent to the student's email" do
      expect(email.to).to eq [student.email]
    end

    it "has the correct subject" do
      expect(email.subject).to eq "#{course.courseno} - #{assignment.name} Submitted"
    end

    describe "text part body" do
      subject { text_part.body }

      it_behaves_like "a complete email body"

      it "doesn't include a template" do
        should_not include "Regents of The University of Michigan"
      end
    end

    describe "html part body" do
      subject { html_part.body }

      it_behaves_like "a complete email body"

      it "should use include a template" do
        should include "Regents of The University of Michigan"
      end

      it "declares a doctype" do
        should include "DOCTYPE"
      end
    end
  end
end
