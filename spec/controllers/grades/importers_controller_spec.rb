require "rails_spec_helper"

describe Grades::ImportersController do
  let(:world) { World.create.with(:course, :assignment, :student, :grade) }
  before { allow(controller).to receive(:current_course).and_return world.course }

  context "as a professor" do
    before do
      membership = create :professor_course_membership, course: world.course
      login_user membership.user
    end

    describe "GET download" do
      it "returns sample csv data" do
        get :download, assignment_id: world.assignment.id, importer_provider_id: :csv, format: :csv

        expect(response.body).to \
          include("First Name,Last Name,Email,Score,Feedback")
      end
    end

    describe "POST upload" do
      render_views

      let(:file) { fixture_file "grades.csv", "text/csv" }

      it "renders the results from the import" do
        world.student.reload.update_attribute :email, "robert@example.com"
        second_student = create(:user, username: "jimmy")
        second_student.courses << world.course

        post :upload, assignment_id: world.assignment.id, importer_provider_id: :csv, file: file

        expect(response).to render_template :import_results
        expect(response.body).to include "2 Grades Imported Successfully"
      end

      it "enqueues the resque job to update the grades" do
        world.student.reload.update_attribute :email, "robert@example.com"
        second_student = create(:user, username: "jimmy")
        second_student.courses << world.course
        ResqueSpec.reset!

        post :upload, assignment_id: world.assignment.id, importer_provider_id: :csv, file: file

        expect(GradeUpdaterJob).to have_queue_size_of(2)
      end

      context "with students that are not part of the current course" do
        it "renders any errors that have occured" do
          post :upload, assignment_id: world.assignment.id, importer_provider_id: :csv, file: file

          expect(response.body).to include "3 Grades Not Imported"
          expect(response.body).to include "Student not found in course"
        end
      end

      context "without a file to import with" do
        it "renders the missing file error" do
          post :upload, assignment_id: world.assignment.id, importer_provider_id: :csv

          expect(flash[:notice]).to eq("File is missing")
          expect(response).to redirect_to(assignment_grades_importer_path(world.assignment, :csv))
        end
      end
    end
  end

  context "as a student" do
    before { login_user world.student }

    describe "GET download" do
      it "redirects back to the root" do
        expect(get :download, { assignment_id: world.assignment.id, importer_provider_id: :csv }).to \
          redirect_to(:root)
      end
    end

    describe "GET show" do
      it "redirects back to the root" do
        expect(get :show, { assignment_id: world.assignment.id, provider_id: :csv }).to \
          redirect_to(:root)
      end
    end

    describe "POST upload" do
      it "redirects back to the root" do
        expect(post :upload, { assignment_id: world.assignment.id, importer_provider_id: :csv }).to \
          redirect_to(:root)
      end
    end
  end
end
