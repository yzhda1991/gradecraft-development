require "rails_spec_helper"

describe NotificationMailer do
  let(:email) { ActionMailer::Base.deliveries.last }
  let(:sender) { NotificationMailer::SENDER_EMAIL }
  let(:admin_email) { NotificationMailer::ADMIN_EMAIL }
  let(:text_part) { email.body.parts.detect {|part| part.content_type.match "text/plain" }}

  describe "#grade_export" do
    let(:professor) { create(:user) }
    let(:course) { create(:course) }
    let(:csv_data) { "stuff,that,is,separated" }

    before(:each) do
      NotificationMailer.grade_export(course, professor, csv_data).deliver_now
    end

    it "is sent from gradecraft's default mailer email" do
      expect(email.from).to eq [sender]
    end

    it "is sent to the professor's email" do
      expect(email.to).to eq [professor.email]
    end

    it "has an appropriate subject" do
      expect(email.subject).to eq "Grade export for #{course.name} is attached"
    end

    it "BCC's the email to the gradecraft admin" do
      expect(email.bcc).to eq [admin_email]
    end

    describe "attachments" do
      subject { email.attachments.first }

      it "should have one attachment" do
        expect(email.attachments.size).to eq(1)
      end

      it "should be a Mail::Part object" do
        expect(subject.class).to eq(Mail::Part)
      end

      it "should have the right mime type" do
        expect(subject.mime_type).to eq("text/csv")
      end

      it "should use the correct filename" do
        expect(subject.filename).to eq("grade_export_#{course.id}.csv")
      end
    end

    describe "text part body" do
      subject { text_part.body }
      it "includes the professor's first name" do
        should include professor.first_name
      end

      it "includes the course name" do
        should include course.name
      end

      it "doesn't include a template" do
        should_not include "Regents of The University of Michigan"
      end
    end
  end
end
