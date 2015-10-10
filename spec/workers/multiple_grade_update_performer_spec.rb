require 'spec_helper'

RSpec.describe MultipleGradeUpdatePerformer, type: :background_job do
  let(:grades) { create_list(:grade, 2) }
  let(:grade_ids) { grades.collect(&:id) }
  let(:attrs) {{ grade_ids: grade_ids }}
  let(:performer) { MultipleGradeUpdatePerformer.new(attrs) }
  subject { performer }

  describe "public methods" do
    describe "setup" do
      it "should fetch the user and set it to user" do
        expect(subject).to receive(:fetch_grades_with_assignment).and_return grades
        subject.setup
        expect(subject.instance_variable_get(:@grades)).to eq(grades)
      end
    end

    describe "do_the_work" do
      subject { performer.do_the_work }
      after(:each) { subject }

      it "should require that the save scores method succeeds" do
        expect(performer).to receive(:require_save_scores_success).exactly(grades.size).times
      end

      it "should require that the notify released method succeeds" do
        expect(performer).to receive(:require_notify_released_success).exactly(grades.size).times
      end

      it "should call require_save_scores_success() for each grade" do
        grades.each do |grade|
          expect(performer).to receive(:require_save_scores_success).with(grade)
        end
      end

      it "should call require_notify_released_success() for each grade" do
        grades.each do |grade|
          expect(performer).to receive(:require_notify_released_success).with(grade)
        end
      end
    end

    describe "require_saved_scores_success" do
      let(:save_scores_messages) { double(:save_scores_messages) }
      subject do
        grades.each do |grade|
          performer.instance_eval { require_save_scores_success(grade) }
        end
      end

      it "should require success with notify released messages" do
        grades.each do |grade|
          allow(performer).to receive(:save_scores_messages).with(grade) { save_scores_messages }
          expect(performer).to receive(:require_success).with(save_scores_messages)
        end
        subject
      end

      context "@grade.save_student_and_team_scores succeeds" do
        before(:each) do
          grades.each do |grade|
            allow(grade).to receive_messages(save_student_and_team_scores: true)
          end
        end

        it "should return the successful value" do
          expect(performer).to receive(:require_success) { true }.exactly(grades.size).times
          subject
        end

        it "should change the number of outcomes" do
          expect{ subject }.to change{ performer.outcomes.size }.by(grades.size)
        end

        it "should create a successful outcome" do
          subject
          grades.each_with_index do |grade,index|
            expect(performer.outcomes[index].success?).to be_truthy
          end
        end

        it "should use the proper message in the outcome" do
          subject
          grades.each_with_index do |grade,index|
            expect(performer.outcome_messages[index]).to match(/saved successfully for grade/)
          end
        end
      end

      context "@grade.save_student_and_team_scores fails" do
        before(:each) do
          grades.each do |grade|
            allow(grade).to receive_messages(save_student_and_team_scores: nil)
          end
        end

        it "should return the successful value" do
          expect(performer).to receive(:require_success) { nil }.exactly(grades.size).times
          subject
        end

        it "should change the number of outcomes" do
          expect{ subject }.to change{ performer.outcomes.size }.by(grades.size)
        end

        it "should create a failed outcome" do
          subject
          grades.each_with_index do |grade,index|
            expect(performer.outcomes[index].failure?).to be_truthy
          end
        end

        it "should use the correct message in the outcome" do
          subject
          grades.each_with_index do |grade,index|
            expect(performer.outcome_messages[index]).to match(/scores failed to save/)
          end
        end
      end
    end

    describe "require_notify_released_success" do
      let(:notify_released_messages) { double(:notify_released_messages) }
      let(:notify_grade_released) { double(:notify_grade_released) }
      let(:notify_released_result) { double(:notify_released_result) }
      let(:performer_grade) { performer.instance_variable_get(:@grade) }
      subject do
        grades.each do |grade|
          performer.instance_eval { require_notify_released_success(grade) }
        end
      end

      context "@grade assignment is set to notify on release" do
        before(:each) do
          grades.each do |grade|
            allow(grade).to receive_message_chain(:assignment, :notify_released?) { true }
          end
        end

        it "should require success with notify released messages" do
          allow(performer).to receive_messages(notify_released_messages: notify_released_messages)
          expect(performer).to receive(:require_success).with(notify_released_messages).exactly(grades.size).times
          subject
        end

        it "should render the value of notify_grade_released" do
          allow(performer).to receive(:notify_grade_released) { true }
          expect(performer).to receive(:require_success) { true }.exactly(grades.size).times
          subject
        end

        it "should return the result of notify_grade_released" do
          allow(performer).to receive_messages(notify_grade_released: notify_released_result)
          grades.each do |grade|
            expect(performer.instance_eval { require_notify_released_success(grade) }.result)
              .to eq(notify_released_result)
          end
        end

        it "should change the number of outcomes" do
          expect{ subject }.to change{ performer.outcomes.size }.by(grades.size)
        end

        it "should create a successful outcome" do
          subject
          grades.each_with_index do |grade,index|
            expect(performer.outcomes[index].success?).to be_truthy
          end
        end

        it "should use the correct message in the outcome" do
          subject
          grades.each_with_index do |grade,index|
            expect(performer.outcome_messages[index]).to match(/Successfully sent notification/)
          end
        end
      end

      context "@grade assignment is not set to notify on release" do
        before(:each) do
          grades.each do |grade|
            allow(grade).to receive_message_chain(:assignment, :notify_released?).and_return false
          end
        end

        it "should not trigger the require success" do
          expect(performer).not_to receive(:require_success)
          subject
        end

        it "should return nil" do
          grades.each do |grade|
            expect{ performer.instance_eval { require_notify_released_success(grade)}.to eq(nil) }
          end
        end
      end
    end
  end

  describe "fetch_grades_with_assignment" do
    subject { performer.instance_eval{ fetch_grades_with_assignment } }
    let(:include_result) { double(:include_result).as_null_object }

    it "should find a grade where the id matches @attrs[:grade_id]" do
      allow(Grade).to receive(:where) { include_result }
      expect(Grade).to receive(:where).with(id: grade_ids)
      performer
    end

    it "should include the assignment" do
      allow(Grade).to receive(:where) { include_result }
      expect(include_result).to receive(:includes).with(:assignment)
      subject
    end

    it "should load the first one" do
      expect(Grade).to receive_message_chain(:where, :includes, :load)
      performer
    end

    it "should return the actual grade" do
      expect(subject.to_a).to eq(grades)
    end

    it "should have included the assignment" do
      subject
      grades.each do |grade|
        expect{ grade.assignment }.not_to make_database_queries
      end
    end
  end

  describe "notify_grade_released" do
    let(:mailer_double) { double(:mailer).as_null_object }
    before(:each) { allow(NotificationMailer).to receive(:grade_released).and_return(mailer_double) }
    subject do
      grades.each do |grade|
        performer.instance_eval { notify_grade_released(grade) }
      end
    end

    it "should create a new grade released notifier with the grade id" do
      grades.each do |grade|
        expect(NotificationMailer).to receive(:grade_released).with(grade.id)
      end
      subject
    end

    it "should deliver the mailer" do
      allow(performer).to receive_messages(grade_released:  mailer_double)
      expect(mailer_double).to receive(:deliver_now).exactly(grades.size).times
      subject
    end
  end

  # NOTE: DONE
  describe "save_scores_messages" do
    subject do
      grades.collect do |grade|
        performer.instance_eval{ save_scores_messages(grade) }
      end
    end

    it "should have a success message" do
      subject.each do |messages|
        expect(messages[:success]).to match('saved successfully')
      end
    end

    it "should have a failure message" do
      subject.each do |messages|
        expect(messages[:failure]).to match('failed to save')
      end
    end

    it "should include the grade id in the success condition" do
      grades.each do |grade|
        messages = performer.instance_eval{ save_scores_messages(grade) }
        expect(messages[:success]).to match("for grade ##{grade.id}")
      end
    end

    it "should include the grade id in the failure condition" do
      grades.each do |grade|
        messages = performer.instance_eval{ save_scores_messages(grade) }
        expect(messages[:failure]).to match("for grade ##{grade.id}")
      end
    end
  end

  describe "notify_released_messages" do
    subject do
      grades.collect do |grade|
        performer.instance_eval{ notify_released_messages(grade) }
      end
    end

    it "should have a success message" do
      subject.each do |messages|
        expect(messages[:success]).to match('Successfully sent notification')
      end
    end

    it "should have a failure message" do
      subject.each do |messages|
        expect(messages[:failure]).to match('Failed to send')
      end
    end

    it "should include the grade id in the success condition" do
      grades.each do |grade|
        messages = performer.instance_eval{ notify_released_messages(grade) }
        expect(messages[:success]).to match("of grade ##{grade.id}")
      end
    end

    it "should include the grade id in the failure condition" do
      grades.each do |grade|
        messages = performer.instance_eval{ notify_released_messages(grade) }
        expect(messages[:failure]).to match("for grade ##{grade.id}")
      end
    end
  end
end
