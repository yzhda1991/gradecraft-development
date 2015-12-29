require 'rails_spec_helper'

RSpec.shared_examples "a complete submissions export email body" do 
  it "includes the professor's first name" do
    should include professor.first_name
  end

  it "includes the assignment name" do
    should include assignment.name
  end

  it "includes the assignment term for the course" do
    should include course.assignment_term.downcase
  end

  it "includes the course name" do
    should include course.name
  end
end

RSpec.shared_examples "a team submissions export email" do 
  it "includes the team term for the course" do
    should include course.team_term.downcase
  end

  it "includes the team name" do
    should include team.name
  end
end

RSpec.shared_examples "a submissions export email with archive data" do 
  it "includes the archive format" do
    should include "ZIP"
  end

  it "includes the archive url" do
    should include exports_path
  end
end

RSpec.shared_examples "a submissions export email without archive data" do 
  it "includes the archive format" do
    should include "ZIP"
  end

  it "doesn't include the archive url" do
    should_not include exports_path
  end
end

# specs for submission notifications that are sent to students
describe NotificationMailer do
  extend Toolkits::Mailers::EmailToolkit::Definitions # brings in helpers for default emails and parts
  define_email_context # taken from the definitions toolkit

  include Toolkits::Mailers::EmailToolkit::SharedExamples # brings in shared examples for emails and parts

  let(:professor) { create(:user) }
  let(:assignment) { create(:assignment, course: course) }
  let(:course) { create(:course, assignment_term: "DECEPTION", team_term: "ASCENSION") }
  let(:team) { create(:team, course: course) }
  let(:team_term) { course.team_term.downcase }
  let(:assignment_term) { course.assignment_term.downcase }
  let(:archive_data) {{ format: "zip", url: "http://aws.com/some-archive-hash" }}

  before(:each) { deliver_email }

  describe "#submissions_export_started" do
    let(:deliver_email) { ExportsMailer.submissions_export_started(professor, assignment).deliver_now }

    it_behaves_like "a gradecraft email to a professor"

    it "BCC's to the gradecraft admin" do
      expect(email.bcc).to eq [admin_email]
    end

    it "has the correct subject" do
      expect(email.subject).to eq "Submissions export for #{ assignment_term } #{assignment.name} is being created"
    end

    describe "text part body" do
      subject { text_part.body }
      it_behaves_like "a complete submissions export email body"
      it_behaves_like "a submissions export email without archive data"
      it_behaves_like "an email text part"
    end

    describe "html part body" do
      subject { html_part.body }
      it_behaves_like "a complete submissions export email body"
      it_behaves_like "a submissions export email without archive data"
      it_behaves_like "an email html part"
    end
  end

  describe "#submissions_export_success" do
    let(:deliver_email) { ExportsMailer.submissions_export_success(professor, assignment).deliver_now }

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
    end

    describe "html part body" do
      subject { html_part.body }
      it_behaves_like "a complete submissions export email body"
      it_behaves_like "a submissions export email with archive data"
      it_behaves_like "an email html part"
    end
  end

  describe "#submissions_export_failure" do
    let(:deliver_email) { ExportsMailer.submissions_export_failure(professor, assignment).deliver_now }

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

  describe "#team_submissions_export_started" do
    let(:deliver_email) { ExportsMailer.team_submissions_export_started(professor, assignment, team).deliver_now }

    it_behaves_like "a gradecraft email to a professor"

    it "BCC's to the gradecraft admin" do
      expect(email.bcc).to eq [admin_email]
    end

    it "has the correct subject" do
      expect(email.subject).to eq "Submissions export for #{team_term} #{team.name} is being created"
    end

    describe "text part body" do
      subject { text_part.body }
      it_behaves_like "a complete submissions export email body"
      it_behaves_like "a team submissions export email"
      it_behaves_like "a submissions export email without archive data"
      it_behaves_like "an email text part"
    end

    describe "html part body" do
      subject { html_part.body }
      it_behaves_like "a complete submissions export email body"
      it_behaves_like "a team submissions export email"
      it_behaves_like "a submissions export email without archive data"
      it_behaves_like "an email html part"
    end
  end

  describe "#team_submissions_export_success" do
    let(:deliver_email) { ExportsMailer.team_submissions_export_success(professor, assignment, team).deliver_now }

    it_behaves_like "a gradecraft email to a professor"

    it "BCC's to the gradecraft admin" do
      expect(email.bcc).to eq [admin_email]
    end

    it "has the correct subject" do
      expect(email.subject).to eq "Submissions export for #{team_term} #{team.name} is ready"
    end

    describe "text part body" do
      subject { text_part.body }
      it_behaves_like "a complete submissions export email body"
      it_behaves_like "a team submissions export email"
      it_behaves_like "a submissions export email with archive data"
      it_behaves_like "an email text part"
    end

    describe "html part body" do
      subject { html_part.body }
      it_behaves_like "a complete submissions export email body"
      it_behaves_like "a team submissions export email"
      it_behaves_like "a submissions export email with archive data"
      it_behaves_like "an email html part"
    end
  end

  describe "#team_submissions_export_failure" do
    let(:deliver_email) { ExportsMailer.team_submissions_export_failure(professor, assignment, team).deliver_now }

    it_behaves_like "a gradecraft email to a professor"

    it "BCC's to the gradecraft admin" do
      expect(email.bcc).to eq [admin_email]
    end

    it "has the correct subject" do
      expect(email.subject).to eq "Submissions export for #{team_term} #{team.name} failed to build"
    end

    describe "text part body" do
      subject { text_part.body }
      it_behaves_like "a complete submissions export email body"
      it_behaves_like "a team submissions export email"
      it_behaves_like "an email text part"
    end

    describe "html part body" do
      subject { html_part.body }
      it_behaves_like "a complete submissions export email body"
      it_behaves_like "a team submissions export email"
      it_behaves_like "an email html part"
    end
  end
end
