describe ExportsMailer do
  extend Toolkits::Mailers::EmailToolkit::Definitions # brings in helpers for default emails and parts
  define_email_context # taken from the definitions toolkit

  include Toolkits::Mailers::EmailToolkit::SharedExamples # brings in shared examples for emails and parts

  describe "#grade_export" do
    let(:professor) { create(:user) }
    let(:course) { create(:course) }
    let(:csv_data) { "stuff,that,is,separated" }
    let(:export_type) { "gradebook export" }

    before(:each) do
      ExportsMailer.gradebook_export(course, professor, export_type, csv_data).deliver_now
    end

    it "is sent from gradecraft's default mailer email" do
      expect(email.from).to eq [sender]
    end

    it "is sent to the professor's email" do
      expect(email.to).to eq [professor.email]
    end

    it "has an appropriate subject" do
      expect(email.subject).to eq "Gradebook export for #{course.name} is attached"
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
        expect(subject.filename).to eq("#{ course.name } Grades - #{ Date.today }.csv")
      end
    end

    describe "text part body" do
      subject { email.text_part.body }
      it "includes the professor's first name" do
        should include_in_mail_body professor.first_name
      end

      it "includes the course name" do
        should include_in_mail_body course.name
      end

      it "doesn't include a template" do
        should_not include "Regents of The University of Michigan"
      end
    end

    describe "html part body" do
      subject { email.html_part.body }
      it "includes the professor's first name" do
        should include_in_mail_body professor.first_name
      end

      it "includes the course name" do
        should include_in_mail_body course.name
      end

      it "does include a template" do
        should include "Regents of The University of Michigan"
      end
    end
  end
end
