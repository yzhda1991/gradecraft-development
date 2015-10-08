require 'spec_helper'

RSpec.describe GradebookExportPerformer, type: :background_job do
  # public methods
  
  describe "public methods" do
    before(:each) do
      @course = create(:course)
      @user = create(:user)
      @performer = GradebookExportPerformer.new(user_id: @user[:id], course_id: @course[:id])
    end

    describe "setup" do
      it "should fetch the user and set it to @user" do
        expect(@performer).to receive(:fetch_user).and_return @user
        @performer.setup
        expect(@performer.instance_variable_get(:@user)).to eq(@user)
      end

      it "should fetch the course and set it to @course" do
        expect(@performer).to receive(:fetch_course).and_return @course
        @performer.setup
        expect(@performer.instance_variable_get(:@course)).to eq(@course)
      end
    end

    describe "do_the_work" do
      context "both course and user present" do
        before(:each) do
          @performer.setup # fetch course and user
        end

        after(:each) do
          @performer.do_the_work
        end

        it "should require success" do
          expect(@performer).to receive(:require_success)
        end

        it "should add an outcome to @performer.outcomes" do
          expect { @performer.do_the_work }.to change { @performer.outcomes.size }.by(1)
        end

        it "should fetch the csv data" do
          expect(@performer).to receive(:fetch_csv_data)
        end

        it "should mail notification that the gradebook was exported" do
          expect(@performer).to receive(:notify_gradebook_export)
        end

        it "should return the result of notify_gradebook_export" do
          @export_result = double(:export_result)
          allow(@performer).to receive_messages(notify_gradebook_export: @export_result)
          expect(@performer).to receive(:require_success).and_return(@export_result)
        end
      end

      context "either course or user are not present" do
        # omit @performer.setup so @user and @course are nil

        it "should not require success" do
          expect(@performer).not_to receive(:require_success)
          @performer.do_the_work
        end

        it "should return nil" do
          expect(@performer.do_the_work).to eq(nil)
        end
      end
    end
  end


  # private methods
  
  describe "fetch_user" do
   it "should find the user by id" do
   end
  end

  describe "fetch_course" do
    it "should find the course by id" do
    end
  end

  describe "fetch_csv_data" do
    it "should find the csv gradebook for the course" do
    end
  end

  describe "notify_gradebook_export" do
    it "should deliver a notification that the gradebook was sent" do
    end
  end
end
