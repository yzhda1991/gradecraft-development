require "rails_spec_helper"

RSpec.shared_examples "a complete earned badge email body" do
  it "includes the student's first name" do
    should include student.first_name
  end

  it "includes the badge name" do
    should include earned_badge.badge.name
  end

  it "includes the course's term for 'badge'" do
    should include course.badge_term
  end

  it "includes the badge term for the course" do
    should include course.badge_term.pluralize.downcase
  end

  it "includes the course name" do
    should include course.name
  end
end

# specs for submission notifications that are sent to students
describe NotificationMailer do
  let(:deliver_email) { NotificationMailer.earned_badge_awarded(earned_badge.id).deliver_now }
  let(:email) { ActionMailer::Base.deliveries.last }
  let(:sender) { NotificationMailer::SENDER_EMAIL }
  let(:text_part) { email.body.parts.detect {|part| part.content_type.match "text/plain" }}
  let(:html_part) { email.body.parts.detect {|part| part.content_type.match "text/html" }}

  let(:student) { create(:user) }
  let(:course) { create(:course, assignment_term: "whifflebox") }
  let(:badge) { create(:badge, icon: "snake.jpg") }
  let(:earned_badge) { create(:earned_badge, earned_badge_attrs.merge(feedback: "You did a really great job.")) }
  let(:earned_badge_attrs) {{ student: student, course: course, badge: badge }}

  describe "#earned_badge_awarded" do
    before(:each) { deliver_email }

    describe "headers" do
      it "is sent from gradecraft's default mailer email" do
        expect(email.from).to eq [sender]
      end

      it "is sent to the student's email" do
        expect(email.to).to eq [student.email]
      end

      it "has the correct subject" do
        expect(email.subject).to eq "#{course.courseno} - You've earned a new #{course.badge_term}!"
      end
    end

    describe "text part body" do
      subject { text_part.body }

      it_behaves_like "a complete earned badge email body"

      it "doesn't include a template" do
        should_not include "Regents of The University of Michigan"
      end
    end

    describe "html part body" do

      describe "persistent email behaviors" do
        subject { html_part.body }

        it_behaves_like "a complete earned badge email body"

        # this isn't included in the text part
        it "includes the badge icon" do
          should include earned_badge.badge.icon
        end

        it "should use include a template" do
          should include "Regents of The University of Michigan"
        end

        it "declares a doctype" do
          should include "DOCTYPE"
        end
      end

      describe "earned badge feedback" do
        context "earned badge has professor feedback" do
          it "should include the feedback and surrounding text" do
            expect(html_part.body).to include("Your instructor said:")
            expect(html_part.body).to include("You did a really great job.")
          end
        end

        context "earned badge doesn't have professor feedback" do
          # this doesn't include feedback in the earned badge attributes
          let(:earned_badge) { create(:earned_badge, earned_badge_attrs) }

          it "should not include the feedback" do
            expect(html_part.body).not_to include("Your instructor said:")
          end
        end
      end
    end
  end
end
