require 'rails_spec_helper'

RSpec.describe GradebookExportPerformer, type: :background_job do
  # public methods
  let(:course) { create(:course) }
  let(:user) { create(:user) }
  let(:attrs) {{ user_id: user[:id], course_id: course[:id] }}
  let(:performer) { GradebookExportPerformer.new(attrs) }
  subject { performer }

  describe "public methods" do

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
          expect(subject).to receive(:require_success).exactly(2).times
        end

        it "should add an outcome to subject.outcomes" do
          expect { subject.do_the_work }.to change { subject.outcomes.size }.by(2)
        end

        it "should fetch the csv data" do
          allow(subject).to receive(:fetch_csv_data).and_return "some,csv,data"
          expect(subject).to receive(:fetch_csv_data)
        end

        it "should mail notification that the gradebook was exported" do
          expect(subject).to receive(:notify_gradebook_export)
        end

        it "should return the result of notify_gradebook_export" do
          @export_result = double(:export_result)
          allow(subject).to receive_messages(notify_gradebook_export: @export_result)
          allow(subject).to receive(:fetch_csv_data).and_return "some,csv,data"
          expect(subject).to receive(:require_success).and_return(@export_result)
          expect(subject).to receive(:require_success).and_return("some,csv,data")
        end

        describe "require_success" do
          describe "notify_gradebook_export requirement" do
            context "block outcome fails" do
              it "should add the :success outcome message to @outcome_messages" do
                allow(subject).to receive_messages(notify_gradebook_export: true)
                subject.do_the_work
                expect(subject.outcome_messages.last).to match("was successfully delivered")
              end
            end

            context "block outcome succeeds" do
              it "should add the :failure outcome message to @outcome_messages" do
                allow(subject).to receive_messages(notify_gradebook_export: false)
                subject.do_the_work
                expect(subject.outcome_messages.last).to match("was not delivered")
              end
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

      it "should call csv_gradebook on the course" do
        performer.instance_variable_set(:@course, course_double)
        expect(course_double).to receive(:csv_gradebook)
        subject
      end

      it "should find the csv gradebook for the course and return it as a huge string" do
        expect(subject.class).to eq(String)
      end

      it "should return a string in valid CSV format" do
        expect(CSV.parse(subject).class).to eq(Array)
      end
    end

    describe "notify_gradebook_export" do
      subject { performer.instance_eval { notify_gradebook_export } }
      let(:csv_data) { performer.instance_variable_get(:@csv_data) }
      let(:csv_double) { double(:csv) }
      after(:each) { subject }
      before(:each) { allow(NotificationMailer).to receive(:gradebook_export).and_return(csv_double) }

      it "should create a new gradebook export notifier with @course, @user, and @csv_data" do
        performer.instance_eval { fetch_csv_data }
        expect(NotificationMailer).to receive(:gradebook_export).with(course, user, csv_data)
        expect(csv_double).to receive(:deliver_now)
      end

      it "should deliver the mailer" do
        allow(performer).to receive_messages(gradebook_export:  csv_double)
        expect(csv_double).to receive(:deliver_now)
      end
    end

    describe "fetch_csv_messages" do
      subject { performer.instance_eval{fetch_csv_messages} }
      it "should have a success message" do
        expect(subject[:success]).to match('Successfully fetched')
      end

      it "should have a failure message" do
        expect(subject[:failure]).to match('Failed to fetch CSV')
      end
    end

    describe "notification_messages" do
      subject { performer.instance_eval{notification_messages} }
      it "should have a success message" do
        expect(subject[:success]).to match('was successfully delivered')
      end

      it "should have a failure message" do
        expect(subject[:failure]).to match('was not delivered')
      end
    end
  end
end
