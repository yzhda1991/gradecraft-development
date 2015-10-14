require 'spec_helper'

RSpec.describe GradeExportPerformer, type: :background_job do
  # public methods
  let(:course) { create(:course) }
  let(:user) { create(:user) }
  let(:attrs) {{ user_id: user[:id], course_id: course[:id] }}
  let(:performer) { GradeExportPerformer.new(attrs) }
  subject { GradeExportPerformer.new(attrs) }

  describe "public methods" do
    describe "initialize" do
    end

    describe "setup" do
      it "should fetch the user and set it to user" do
        expect(subject).to receive(:fetch_user).and_return user
        subject.setup
        expect(subject.instance_variable_get(:@user)).to eq(user)
      end

      it "should fetch the course and set it to course" do
        expect(subject).to receive(:fetch_course).and_return course
        subject.setup
        expect(subject.instance_variable_get(:@course)).to eq(course)
      end
    end

    describe "do_the_work" do
      context "both course and user present" do
        after(:each) do
          subject.do_the_work
        end

        it "should require success" do
          expect(subject).to receive(:require_success)
        end

        it "should add an outcome to subject.outcomes" do
          expect { subject.do_the_work }.to change { subject.outcomes.size }.by(1)
        end

        it "should fetch the csv data" do
          expect(subject).to receive(:fetch_csv_data)
        end

        it "should mail notification that the grade was exported" do
          expect(subject).to receive(:notify_grade_export)
        end

        it "should return the result of notify_grade_export" do
          @export_result = double(:export_result)
          allow(subject).to receive_messages(notify_grade_export: @export_result)
          expect(subject).to receive(:require_success).and_return(@export_result)
        end

        describe "require_success" do
          context "block outcome fails" do
            it "should add the :failure outcome message to @outcome_messages" do
              allow(subject).to receive_messages(notify_grade_export: false)
              subject.do_the_work
              expect(subject.outcome_messages.first).to match("was not delivered")
            end
          end

          context "block outcome succeeds" do
            it "should add the :succeeds outcome message to @outcome_messages" do
              allow(subject).to receive_messages(notify_grade_export: false)
              subject.do_the_work
              expect(subject.outcome_messages.first).to match("was not delivered")
            end
          end
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

    describe "messages" do
      subject { performer.instance_eval{messages} }
      it "should have a success message" do
        expect(subject[:success]).to match('successfully delivered')
      end

      it "should have a failure message" do
        expect(subject[:failure]).to match('was not delivered')
      end
    end
  end
end
