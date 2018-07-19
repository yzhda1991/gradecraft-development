# specs for submission notifications that are sent to students
describe CourseAnalyticsExportsMailer do

  # brings in helpers for default emails and parts
  extend Toolkits::Mailers::EmailToolkit::Definitions
  define_email_context # defined in EmailToolkit::Definitions

  # brings in shared examples for emails and parts
  include Toolkits::Mailers::EmailToolkit::SharedExamples

  # include the #secure_downloads_url so we can test that it's being included
  include SecureTokenHelper

  let(:export) { create :course_analytics_export }
  let(:owner) { export.owner }
  let(:course) { export.course }

  let(:archive_data) do
    { format: "zip", url: "http://aws.com/some-archive-hash" }
  end

  before(:each) { deliver_email }

  describe "#export_success" do
    let(:deliver_email) do
      described_class.export_success(export: export, token: token).deliver_now
    end

    let(:token) do
      SecureToken.create target: export,
        user_id: owner.id,
        course_id: course.id
    end

    it "is sent from gradecraft's default mailer email" do
      expect(email.from).to eq [sender]
    end

    it "is sent to the owner's email" do
      expect(email.to).to eq [owner.email]
    end

    it "BCC's to the gradecraft admin" do
      expect(email.bcc).to eq [admin_email]
    end

    it "has the correct subject" do
      expect(email.subject).to eq \
        "Course Analytics Export for #{course.course_number} - #{course.name} " \
        "is ready"
    end

    describe "text part body" do
      subject { text_part.body }

      it "includes the owner's first name" do
        should include_in_mail_body owner.first_name
      end

      it "includes the course name" do
        should include_in_mail_body course.name
      end

      it "doesn't declare a doctype" do
        should_not include "DOCTYPE"
      end

      it "includes the secure download url" do
        expect(subject).to include secure_download_url(token)
      end

      it "includes the archive url" do
        should include downloads_path
      end

      it "includes the archive format" do
        should include "ZIP"
      end
    end

    describe "html part body" do
      subject { html_part.body }

      it "includes the owner's first name" do
        should include_in_mail_body owner.first_name
      end

      it "includes the course name" do
        should include_in_mail_body course.name
      end

      it "declares a doctype" do
        should include "DOCTYPE"
      end

      it "includes the secure download url" do
        expect(subject).to include secure_download_url(token)
      end

      it "includes the archive url" do
        should include downloads_path
      end

      it "includes the archive format" do
        should include "ZIP"
      end
    end
  end

  describe "#export_failure" do
    let(:deliver_email) do
       described_class.export_failure(export: export).deliver_now
    end

    it "is sent from gradecraft's default mailer email" do
      expect(email.from).to eq [sender]
    end

    it "is sent to the owner's email" do
      expect(email.to).to eq [owner.email]
    end

    it "BCC's to the gradecraft admin" do
      expect(email.bcc).to eq [admin_email]
    end

    it "has the correct subject" do
      expect(email.subject).to eq \
        "Course Analytics Export for #{course.course_number} - #{course.name} " \
        "failed to build"
    end

    describe "text part body" do
      subject { text_part.body }

      it "includes the owner's first name" do
        should include_in_mail_body owner.first_name
      end

      it "includes the course name" do
        should include_in_mail_body course.name
      end

      it "doesn't declare a doctype" do
        should_not include "DOCTYPE"
      end
    end

    describe "html part body" do
      subject { html_part.body }

      it "includes the owner's first name" do
        should include_in_mail_body owner.first_name
      end

      it "includes the course name" do
        should include_in_mail_body course.name
      end

      it "declares a doctype" do
        should include "DOCTYPE"
      end
    end
  end

end
