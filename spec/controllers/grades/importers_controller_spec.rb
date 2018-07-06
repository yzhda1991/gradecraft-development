describe Grades::ImportersController do
  let(:course) { build :course }
  let(:assignment) { create :assignment, course: course }
  let(:grade) { build_stubbed :grade, student: student, assignment: assignment, course: course }
  let(:student) { create :user, courses: [course], role: :student }

  before { allow(controller).to receive(:current_course).and_return course }

  context "as a professor" do
    let(:professor) { create :user, courses: [course], role: :professor }

    before { login_user professor }

    describe "GET assignments" do
      let(:provider) { :canvas }
      let(:course_id) { "COURSE_ID" }
      let(:access_token) { "BLAH" }
      let(:syllabus) { double :syllabus, course: {}, assignments: [] }
      let!(:user_authorization) do
        create :user_authorization, :canvas, user: professor, access_token: access_token,
          expires_at: 2.days.from_now
      end

      before(:each) do
        allow(ActiveLMS::Syllabus).to receive(:new).with("canvas", access_token).and_return \
          syllabus
      end
    end

    describe "GET download" do
      it "returns sample csv data" do
        get :download, params: { assignment_id: assignment.id, importer_provider_id: :csv }, format: :csv

        expect(response.body).to \
          include("First Name,Last Name,Email,Score,Feedback")
      end
    end

    describe "POST upload" do
      render_views

      let(:file) { fixture_file "grades.csv", "text/csv" }
      let(:bad_file) { fixture_file "grades.xlsx"}

      it "renders the results from the import" do
        student.reload.update_attribute :email, "robert@example.com"
        second_student = create(:user, username: "jimmy", courses: [course], role: :student)

        post :upload, params: { assignment_id: assignment.id, importer_provider_id: :csv, file: file }

        expect(response).to render_template :import_results
        expect(response.body).to include "2 Grades Imported Successfully"
      end

      it "enqueues the resque job to update the grades" do
        student.reload.update_attribute :email, "robert@example.com"
        second_student = create(:user, username: "jimmy", courses: [course], role: :student)
        ResqueSpec.reset!

        post :upload, params: { assignment_id: assignment.id, importer_provider_id: :csv, file: file }

        expect(GradeUpdaterJob).to have_queue_size_of(2)
      end

      context "with students that are not part of the current course" do
        it "renders any errors that have occured" do
          post :upload, params: { assignment_id: assignment.id, importer_provider_id: :csv, file: file }

          expect(response.body).to include "6 Grades Not Imported"
          expect(response.body).to include "Student not found in course"
        end
      end

      context "without a file to import with" do
        it "renders the missing file error" do
          post :upload, params: { assignment_id: assignment.id, importer_provider_id: :csv }

          expect(flash[:notice]).to eq("File is missing")
          expect(response).to redirect_to(assignment_grades_importer_path(assignment, :csv))
        end
      end

      context "with a file that is not csv to import with" do
        it "renders the file not csv error" do
          post :upload, params: { assignment_id: assignment.id, importer_provider_id: :csv, file: bad_file }

          expect(flash[:notice]).to eq("We're sorry, the grade import utility only supports .csv files. Please try again using a .csv file.")
          expect(response).to redirect_to(assignment_grades_importer_path(assignment, :csv))
        end
      end
    end

    describe "GET grades" do
      let(:course_id) { "COURSE_ID" }
      let(:assignment_ids) { ["ASSIGNMENT_1"] }
      let(:importer_provider_id) { :canvas }

      it "links the provider credentials if the provider is canvas" do
        expect_any_instance_of(CanvasAuthorization).to receive(:link_canvas_credentials)
        get :grades, params: { importer_provider_id: importer_provider_id,
          assignment_id: assignment.id, id: course_id, assignment_ids: assignment_ids }
      end
    end

    describe "POST grades_import" do
      let(:access_token) { "BLAH" }
      let(:assignment_ids) { ["ASSIGNMENT_1"] }
      let(:course_id) { "COURSE_ID" }
      let(:grade_ids) { ["GRADE1", "GRADE2"] }
      let(:result) { double :result, success?: true, message: "" }
      let!(:user_authorization) do
        create :user_authorization, :canvas, user: professor, access_token: access_token,
          expires_at: 2.days.from_now
      end

      before do
        allow(Services::ImportsLMSGrades).to receive(:call).and_return result
      end

      it "links the provider credentials if the provider is canvas" do
        expect_any_instance_of(CanvasAuthorization).to receive(:link_canvas_credentials)
        post :grades_import, params: { importer_provider_id: "canvas",
          assignment_id: assignment.id, id: course_id, grade_ids: grade_ids,
          assignment_ids: assignment_ids }
      end

      it "imports the selected grades" do
        expect(Services::ImportsLMSGrades).to \
          receive(:call).with("canvas", access_token, course_id,
                                assignment_ids, grade_ids, assignment,
                                professor)
            .and_return result

        post :grades_import, params: { importer_provider_id: "canvas",
          assignment_id: assignment.id, id: course_id, grade_ids: grade_ids,
          assignment_ids: assignment_ids }
      end

      it "renders the results" do
        post :grades_import, params: { importer_provider_id: "canvas",
          assignment_id: assignment.id, id: course_id, grade_ids: grade_ids,
          assignment_ids: assignment_ids }

        expect(response).to render_template :grades_import_results
      end

      context "with an invalid result" do
        it "re-renders the template with the error" do
          allow(result).to receive(:success?).and_return false
          syllabus = double(course: {}, grades: { data: [] })
          allow(controller).to receive(:syllabus).and_return syllabus

          post :grades_import, params: { importer_provider_id: "canvas",
            assignment_id: assignment.id, id: course_id, grade_ids: grade_ids,
            assignment_ids: assignment_ids }

          expect(response).to render_template :grades
        end
      end
    end
  end

  context "as a student" do
    before { login_user student }

    describe "GET download" do
      it "redirects back to the root" do
        expect(get :download, params: { assignment_id: assignment.id, importer_provider_id: :csv }).to \
          redirect_to(:root)
      end
    end

    describe "GET show" do
      it "redirects back to the root" do
        expect(get :show, params: { assignment_id: assignment.id, provider_id: :csv }).to \
          redirect_to(:root)
      end
    end

    describe "POST upload" do
      it "redirects back to the root" do
        expect(post :upload, params: { assignment_id: assignment.id, importer_provider_id: :csv }).to \
          redirect_to(:root)
      end
    end
  end
end
