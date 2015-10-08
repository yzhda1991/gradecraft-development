require 'spec_helper'

RSpec.describe GradebookExportPerformer, type: :background_job do
  # public methods

  describe "setup" do
    it "should fetch the user and set it to @user" do
    end

    it "should fetch the course and set it to @course" do
    end
  end

  describe "do_the_work" do
    context "both course and user present" do
      it "should require success" do
      end

      it "should fetch the csv data" do
      end

      it "should mail notification that the gradebook was exported" do
      end

      it "should return the result of notify_gradebook_export" do
      end
    end

    context "either course or user are not present" do
      it "should not require success" do
      end

      it "should return nil" do
      end
    end
  end

  describe "outcome_messages" do
    context "success" do
      it "should say that the notification was delivered" do
      end
    end

    context "failure" do
      it "should say that the notification was not delivered" do

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
