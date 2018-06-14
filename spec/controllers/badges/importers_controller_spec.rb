describe Badges::ImportersController do
  let(:course) { build :course }
  let(:badge) { create :badge, name: "Fancy Badge", course: course }
  let!(:student) { create(:course_membership, :student, course: course, active: true).user }

  before { allow(controller).to receive(:current_course).and_return course }

  context "as a professor" do
    let(:professor) { create :user, courses: [course], role: :professor }

    before { login_user professor }

    describe "GET show" do
      it "renders the correct template if the importer provider id is allowed" do
        get :show, params: { badge_id: badge, provider_id: :csv }
        expect(response).to render_template :csv
      end
    end

    describe "GET download" do
      it "returns sample csv data" do
        get :download, params: { badge_id: badge.id, importer_provider_id: :csv }, format: :csv

        expect(response.body).to \
          include("First Name,Last Name,Email,New Awarded Count,Feedback (optional),Current Earned Count")
      end
    end

    describe "POST upload" do
      let(:file) { fixture_file "badges.csv", "text/csv" }
      let(:bad_file) { fixture_file "badges.xlsx"}

      it "renders the results from the import" do
        student.reload.update_attribute :email, "seamus.finnigan@hogwarts.edu"
        second_student = create(:course_membership, course: course, active: true).user

        post :upload, params: { badge_id: badge.id, importer_provider_id: :csv, file: file }

        expect(response).to render_template :import_results
        expect(assigns(:result).successful.count).to eq 2
      end

      context "with students that are not part of the current course" do
        it "assigns the number of unsuccessful imports" do
          post :upload, params: { badge_id: badge.id, importer_provider_id: :csv, file: file }

          expect(assigns(:result).unsuccessful.count).to eq 7
          expect(assigns(:result).unsuccessful.map { |r| r[:errors] }).to \
            all eq "Active student not found in course"
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
