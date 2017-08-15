describe Badges::ImportersController do
  let(:course) { build :course }
  let(:badge) { create :badge, name: "Fancy Badge", course: course }
  let!(:student) { create(:course_membership, :student, course: course, active: true).user }

  before { allow(controller).to receive(:current_course).and_return course }

  context "as a professor" do
    let(:professor) { build :user, courses: [course], role: :professor }

    before { login_user professor }

    describe "GET download" do
      it "returns sample csv data" do
        get :download, params: { badge_id: badge.id, importer_provider_id: :csv }, format: :csv

        expect(response.body).to \
          include("First Name,Last Name,Email,Current Earned Count,New Awarded Count,Feedback (optional)")
      end
    end

    describe "POST upload" do
      render_views

      let(:file) { fixture_file "badges.csv", "text/csv" }
      let(:bad_file) { fixture_file "badges.xlsx"}

      it "renders the results from the import" do
        student.reload.update_attribute :email, "seamus.finnigan@hogwarts.edu"
        second_student = create(:course_membership, course: course, active: true).user

        post :upload, params: { badge_id: badge.id, importer_provider_id: :csv, file: file }

        expect(response).to render_template :import_results
        expect(response.body).to include "2 Badges Imported Successfully"
      end

      context "with students that are not part of the current course" do
        it "renders any errors that have occured" do
          post :upload, params: { badge_id: badge.id, importer_provider_id: :csv, file: file }

          expect(response.body).to include "7 Badges Not Imported"
          expect(response.body).to include "Active student not found in course"
        end
      end

      context "without a file to import with" do
        it "renders the missing file error" do
          post :upload, params: { badge_id: badge.id, importer_provider_id: :csv }

          expect(flash[:notice]).to eq("File is missing")
          expect(response).to redirect_to(badge_badges_importer_path(badge, :csv))
        end
      end

      context "with a file that is not csv to import with" do
        it "renders the file not csv error" do
          post :upload, params: { badge_id: badge.id, importer_provider_id: :csv, file: bad_file }

          expect(flash[:notice]).to eq("We're sorry, the badge import utility only supports .csv files. Please try again using a .csv file.")
          expect(response).to redirect_to(badge_badges_importer_path(badge, :csv))
        end
      end
    end
  end

  context "as a student" do
    before { login_user student }

    describe "GET download" do
      it "redirects back to the root" do
        expect(get :download, params: { badge_id: badge.id, importer_provider_id: :csv }).to \
          redirect_to(:root)
      end
    end

    describe "GET show" do
      it "redirects back to the root" do
        expect(get :show, params: { badge_id: badge.id, provider_id: :csv }).to \
          redirect_to(:root)
      end
    end

    describe "POST upload" do
      it "redirects back to the root" do
        expect(post :upload, params: { badge_id: badge.id, importer_provider_id: :csv }).to \
          redirect_to(:root)
      end
    end
  end
end
