require 'spec_helper'

RSpec.describe GradebookExportPerformer, type: :background_job do
  # public methods
  
  describe "public methods" do
    let(:course) { create(:course) }
    let(:user) { create(:user) }
    subject { GradebookExportPerformer.new(user_id: user[:id], course_id: course[:id]) }

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
        before(:each) do
          subject.setup # fetch course and user
        end

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

        it "should mail notification that the gradebook was exported" do
          expect(subject).to receive(:notify_gradebook_export)
        end

        it "should return the result of notify_gradebook_export" do
          @export_result = double(:export_result)
          allow(subject).to receive_messages(notify_gradebook_export: @export_result)
          expect(subject).to receive(:require_success).and_return(@export_result)
        end

        describe "require_success" do
          context "block outcome fails" do
            it "should add the :failure outcome message to @outcome_messages" do
              allow(subject).to receive_messages(notify_gradebook_export: false)
              subject.do_the_work
              expect(subject.outcome_messages.first).to match("was not delivered")
            end
          end

          context "block outcome succeeds" do
            it "should add the :succeeds outcome message to @outcome_messages" do
              allow(subject).to receive_messages(notify_gradebook_export: false)
              subject.do_the_work
              expect(subject.outcome_messages.first).to match("was not delivered")
            end
          end
        end
      end

      context "either course or user are not present" do
        # omit subject.setup so user and course are nil

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
  
  describe "fetch_user" do
   it "should find the user by id" do
     expect(subject.fetch_user).to eq(user)
   end
  end

  describe "fetch_course" do
    it "should find the course by id" do
     expect(subject.fetch_course).to eq(course)
    end
  end

  describe "fetch_csv_data" do
    let(:peformer) { GradebookExportPerformer.new(user_id: user[:id], course_id: course[:id]) }
    subject { performer.fetch_csv_data }

    it "should find the csv gradebook for the course and return it as a huge string" do
      expect(subject.class).to eq(String)
    end

    it "should return a string in valid CSV format" do
      expect(CSV.parse(subject).class).to eq(Array)
    end
  end

  describe "notify_gradebook_export" do
    it "should deliver a notification that the gradebook was sent" do
    end
  end
end
