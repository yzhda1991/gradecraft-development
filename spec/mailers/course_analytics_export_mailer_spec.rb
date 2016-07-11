require "rails_spec_helper"

# specs for submission notifications that are sent to students
describe CourseAnalyticsExportsMailer do

  # brings in helpers for default emails and parts
  extend Toolkits::Mailers::EmailToolkit::Definitions
  define_email_context # defined in EmailToolkit::Definitions

  # brings in shared examples for emails and parts
  include Toolkits::Mailers::EmailToolkit::SharedExamples

  # include the #secure_downloads_url so we can test that it's being included
  include SecureTokenHelper

  let(:export) { create(:course_analytics_export) }
  let(:professor) { export.professor }
  let(:course) { export.course }

  let(:secure_token) do
    create :secure_token,
      user_id: professor.id,
      course_id: course.id,
      target: export
  end

  let(:archive_data) do
    { format: "zip", url: "http://aws.com/some-archive-hash" }
  end

  before(:each) { deliver_email }

  describe "#export_started" do
    let(:deliver_email) do
      ExportsMailer.export_started(
        professor: professor,
        course: course
      ).deliver_now
    end

    it "is sent from gradecraft's default mailer email" do
      expect(email.from).to eq [sender]
    end

    it "is sent to the professor's email" do
      expect(email.to).to eq [professor.email]
    end

    it "BCC's to the gradecraft admin" do
      expect(email.bcc).to eq [admin_email]
    end

    it "has the correct subject" do
      expect(email.subject).to eq \
        "Course Analytics Export for #{course.courseno} - #{course.name} " \
        "is being created"
    end

    describe "text part body" do
      subject { text_part.body }

      it "includes the professor's first name" do
        should include professor.first_name
      end

      it "includes the course name" do
        should include course.name
      end

      it "doesn't declare a doctype" do
        should not include "DOCTYPE"
      end
    end

    describe "html part body" do
      subject { html_part.body }

      it "includes the professor's first name" do
        should include professor.first_name
      end

      it "includes the course name" do
        should include course.name
      end

      it "declares a doctype" do
        should include "DOCTYPE"
      end
    end
  end


  describe "#export_success" do
    let(:deliver_email) do
       described_class.export_success(
         professor: professor,
         export: export,
         token: secure_token
       ).deliver_now
    end

    it "is sent from gradecraft's default mailer email" do
      expect(email.from).to eq [sender]
    end

    it "is sent to the professor's email" do
      expect(email.to).to eq [professor.email]
    end

    it "BCC's to the gradecraft admin" do
      expect(email.bcc).to eq [admin_email]
    end

    it "has the correct subject" do
      expect(email.subject).to eq \
        "Course Analytics Export for #{course.courseno} - #{course.name} " \
        "is ready"
    end

    describe "text part body" do
      subject { text_part.body }

      it "includes the professor's first name" do
        should include professor.first_name
      end

      it "includes the course name" do
        should include course.name
      end

      it "doesn't declare a doctype" do
        should not include "DOCTYPE"
      end

      it "includes the secure download url" do
        expect(subject).to include secure_download_url(secure_token)
      end

      it "includes the archive url" do
        should include exports_path
      end

      it "includes the archive format" do
        should include "ZIP"
      end
    end

    describe "html part body" do
      subject { html_part.body }

      it "includes the professor's first name" do
        should include professor.first_name
      end

      it "includes the course name" do
        should include course.name
      end

      it "declares a doctype" do
        should include "DOCTYPE"
      end

      it "includes the secure download url" do
        expect(subject).to include secure_download_url(secure_token)
      end

      it "includes the archive url" do
        should include exports_path
      end

      it "includes the archive format" do
        should include "ZIP"
      end
    end
  end

  describe "#export_failure" do
    let(:deliver_email) do
       described_class.export_failure(
         professor: professor,
         course: course
       ).deliver_now
    end

    it "is sent from gradecraft's default mailer email" do
      expect(email.from).to eq [sender]
    end

    it "is sent to the professor's email" do
      expect(email.to).to eq [professor.email]
    end

    it "BCC's to the gradecraft admin" do
      expect(email.bcc).to eq [admin_email]
    end

    it "has the correct subject" do
      expect(email.subject).to eq \
        "Course Analytics Export for #{course.courseno} - #{course.name} " \
        "failed to build"
    end

    describe "text part body" do
      subject { text_part.body }

      it "includes the professor's first name" do
        should include professor.first_name
      end

      it "includes the course name" do
        should include course.name
      end

      it "doesn't declare a doctype" do
        should not include "DOCTYPE"
      end
    end

    describe "html part body" do
      subject { html_part.body }

      it "includes the professor's first name" do
        should include professor.first_name
      end

      it "includes the course name" do
        should include course.name
      end

      it "declares a doctype" do
        should include "DOCTYPE"
      end
    end
  end

end
