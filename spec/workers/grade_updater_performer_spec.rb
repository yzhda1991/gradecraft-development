require 'spec_helper'

RSpec.describe GradeUpdatePerformer, type: :background_job do
  # public methods
  let(:grade) { create(:grade) }
  let(:attrs) {{ user_id: user[:id], course_id: course[:id] }}
  let(:performer) { GradeUpdatePerformer.new(attrs) }
  subject { GradeUpdatePerformer.new(attrs) }

  describe "public methods" do
    describe "setup" do
      it "should fetch the user and set it to user" do
        expect(subject).to receive(:fetch_grade_with_assignment).and_return grade
        subject.setup
        expect(subject.instance_variable_get(:@grade)).to eq(grade)
      end
    end

    describe "do_the_work" do
      subject { performer.do_the_work }
      after(:each) { subject }

      it "should require that the saved scores method succeeds" do
        expect(performer).to receive(:require_saved_scores_success)
      end

      it "should require that the notify released method succeeds" do
        expect(performer).to receive(:require_notify_released_success)
      end
    end

    describe_"require_saved_scores_success" do
      let(:saved_scores_messages) { double(:saved_scores_messages) }
      let(:grade) { performer.instance_variable_get(:@grade) }
      subject { performer.instance_eval { require_saved_scores_success }}

      it "should require success with notify released messages" do
        allow(performer).to receive_messages(notify_saved_scores: notify_saved_scores)
        expect(performer).to receive(:require_success).with(saved_scores_messages)
        subject
      end

      context "@grade.save_student_and_team_scores succeeds" do
        before(:each) do
          allow(grade).to_receive_messages(save_student_and_team_scores: true)
        end

        it "should return the successful value" do
          expect(performer).to receive(:require_success) { true }
          subject
        end

        it "should change the number of outcomes" do
          expect(subject).to change{ performer.outcomes.size }.by(1)
        end

        it "should create a successful outcome" do
          subject
          expect(performer.outcomes.first.success?).to be_truthy
        end

        it "should use the proper message in the outcome" do
          subject
          expect(performer.outcome_messages.first).to match(/saved successfully for grade/)
        end
      end

      context "@grade.save_student_and_team_scores fails" do
        before(:each) do
          allow(grade).to_receive_messages(save_student_and_team_scores: nil)
        end

        it "should return the successful value" do
          expect(performer).to receive(:require_success) { nil }
          subject
        end

        it "should change the number of outcomes" do
          expect(subject).to change{ performer.outcomes.size }.by(1)
        end

        it "should create a failed outcome" do
          subject
          expect(performer.outcomes.first.failure?).to be_truthy
        end

        it "should use the correct message in the outcome" do
          subject
          expect(performer.outcome_messages.first).to match(/scores failed to save/)
        end
      end
    end

    describe "require_notify_released_success" do
      subject { performer.instance_eval { require_notify_released_succcess } }
      let(:notify_released_messages) { double(:notify_released_messages) }
      let(:notify_grade_released) { double(:notify_grade_released) }
      let(:grade) { performer.instance_variable_get(:@grade) }

      context "@grade assignment is set to notify on release" do
        before(:each) do
          allow(grade).to receive_message_chain(:assignment, :notify_released?) { true }
        end

        it "should require success with notify released messages" do
          allow(subject).to receive_messages(notify_released_messages: notify_released_messages)
          expect(subject).to receive(:require_success).with(notify_released_messages)
        end

        it "should render the value of notify_grade_released" do
          allow(performer).to receive(:notify_grade_released) { true }
          expect(performer).to receive(:require_success) { true }
          subject
        end

        it "should change the number of outcomes" do
          expect(subject).to change{ performer.outcomes.size }.by(1)
        end

        it "should create a successful outcome" do
          subject
          expect(performer.outcomes.first.success?).to be_truthy
        end

        it "should use the correct message in the outcome" do
          subject
          expect(performer.outcome_messages.first).to match(/successfully sent notification/)
        end
      end

      context "@grade assignment is not set to notify on release" do
        before(:each) do
          allow(grade).to receive_message_chain(:assignment, :notify_released?).and_return false
        end
      end
    end

    describe "" do
        it "should mail notification that the grade was released" do
          expect(subject).to receive(:notify_grade_released)
        end

        it "should return the result of notify_grade_released" do
          @released_result = double(:released_result)
          allow(subject).to receive_messages(notify_grade_released: @released_result)
          expect(subject).to receive(:require_success).and_return(@released_result)
        end
      end

      context "either course or user are not present" do
        # omit subject.setup so user and course are nil
        before(:each) do
          subject.remove_instance_variable(:@course)
          subject.remove_instance_variable(:@user)
        end

        it "should not require success" do
          expect(subject).not_to receive(:require_success)
          subject.do_the_work
        end

        it "should return nil" do
          expect(subject.do_the_work).to eq(nil)
        end
      end
    end
  end


  # private methods
  
  describe "private methods" do
    describe "fetch_user" do
      subject { performer.instance_eval{fetch_user} }
      it "should fetch the user" do
        expect(subject).to eq(user)
      end

      it "should find the course by id" do
        expect(User).to receive(:find).with(user[:id]) { course }
        performer
      end
    end

    describe "fetch_course" do
      subject { performer.instance_eval{fetch_course} }

      it "should fetch the course" do
       expect(subject).to eq(course)
      end

      it "should find the course by id" do
        expect(Course).to receive(:find).with(course[:id]) { course }
        performer
      end
    end

    describe "fetch_csv_data" do
      subject { performer.instance_eval{fetch_csv_data} }
      let(:course_double) { double(:course) }

      it "should call csv_grade on the course" do
        performer.instance_variable_set(:@course, course_double)
        expect(course_double).to receive(:research_grades_csv)
        subject
      end

      it "should find the csv grade for the course and return it as a huge string" do
        expect(subject.class).to eq(String)
      end

      it "should return a string in valid CSV format" do
        expect(CSV.parse(subject).class).to eq(Array)
      end
    end

    describe "notify_grade_export" do
      subject { performer.instance_eval { notify_grade_export } }
      let(:csv_data) { performer.instance_variable_get(:@csv_data) }
      let(:csv_double) { double(:csv) }
      after(:each) { subject }
      before(:each) { allow(NotificationMailer).to receive(:grade_export).and_return(csv_double) }

      it "should create a new grade export notifier with @course, @user, and @csv_data" do
        performer.instance_eval { fetch_csv_data }
        expect(NotificationMailer).to receive(:grade_export).with(course, user, csv_data)
        expect(csv_double).to receive(:deliver_now)
      end

      it "should deliver the mailer" do
        allow(performer).to receive_messages(grade_export:  csv_double)
        expect(csv_double).to receive(:deliver_now)
      end
    end

    # NOTE: DONE
    describe "save_scores_messages" do
      subject { performer.instance_eval{ save_scores_messages } }
      let(:grade_id) { performer.instance_variable_get(:@grade) }

      it "should have a success message" do
        expect(subject[:success]).to match('saved successfully')
      end

      it "should have a failure message" do
        expect(subject[:failure]).to match('failed to save')
      end

      it "should include the grade id in the success condition" do
        expect(subject[:success]).to match(/for grade ##{grade_id}/)
      end

      it "should include the grade id in the failure condition" do
        expect(subject[:failure]).to match(/for grade ##{grade_id}/)
      end
    end

    # NOTE: DONE
    describe "notify_released_messages" do
      subject { performer.instance_eval{ notify_released_messages }

      it "should have a success message" do
        expect(subject[:success]).to match('successfully sent notification')
      end

      it "should have a failure message" do
        expect(subject[:failure]).to match('failed to send')
      end
    end
  end
end
