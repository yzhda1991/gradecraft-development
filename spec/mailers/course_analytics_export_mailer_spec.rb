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

    it_behaves_like "a gradecraft email to a professor"

    it "BCC's to the gradecraft admin" do
      expect(email.bcc).to eq [admin_email]
    end

    it "has the correct subject" do
      expect(email.subject).to eq "Course Analytics Export for #{course.courseno} - #{course.name} is being created"
    end

    describe "text part body" do
      subject { text_part.body }
      it_behaves_like "a complete submissions export email body"
      it_behaves_like "a submissions export email without archive data"

      # should not have an html footer
      it_behaves_like "an email text part"
    end

    describe "html part body" do
      subject { html_part.body }
      it_behaves_like "a complete submissions export email body"
      it_behaves_like "a submissions export email without archive data"

      # should have an html footer
      it_behaves_like "an email html part"
    end
  end

  describe "#export_success" do
    let(:deliver_email) do
      ExportsMailer
        .submissions_export_success(professor, assignment, submissions_export, secure_token)
        .deliver_now
    end

    it_behaves_like "a gradecraft email to a professor"

    it "BCC's to the gradecraft admin" do
      expect(email.bcc).to eq [admin_email]
    end

    it "has the correct subject" do
      expect(email.subject).to eq "Submissions export for #{ assignment_term } #{assignment.name} is ready"
    end

    describe "text part body" do
      subject { text_part.body }
      it_behaves_like "a complete submissions export email body"
      it_behaves_like "a submissions export email with archive data"
      it_behaves_like "an email text part"

      it "includes the secure download url" do
        expect(subject).to include secure_download_url(secure_token)
      end
    end

    describe "html part body" do
      subject { html_part.body }
      it_behaves_like "a complete submissions export email body"
      it_behaves_like "a submissions export email with archive data"
      it_behaves_like "an email html part"

      it "includes the secure download url" do
        expect(subject).to include secure_download_url(secure_token)
      end
    end
  end

  describe "#export_failure" do
    let(:deliver_email) do
      ExportsMailer
        .submissions_export_failure(professor, assignment)
        .deliver_now
    end

    it_behaves_like "a gradecraft email to a professor"

    it "BCC's to the gradecraft admin" do
      expect(email.bcc).to eq [admin_email]
    end

    it "has the correct subject" do
      expect(email.subject).to eq "Submissions export for #{ assignment_term } #{assignment.name} failed to build"
    end

    describe "text part body" do
      subject { text_part.body }
      it_behaves_like "a complete submissions export email body"
      it_behaves_like "an email text part"
    end

    describe "html part body" do
      subject { html_part.body }
      it_behaves_like "a complete submissions export email body"
      it_behaves_like "an email html part"
    end
  end

end
