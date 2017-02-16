require "spec_helper"

describe AnnouncementsController do
  let(:course) { create(:course) }
  let(:student) { create(:course_membership, :student, course: course).user }
  let(:professor) { create(:course_membership, :professor, course: course).user }
  let(:announcement) { create :announcement, course: course }
  
  context "as a student" do
    before(:each) do
      login_user(student)
    end

    describe "GET #show" do
      it "marks the announcement as read by the student" do
        get :show, params: { id: announcement.id }
        expect(announcement.read?(student)).to be_truthy
      end
    end

    describe "GET #new" do
      it "should not allow a student to try and create an announcement" do
        expect { get :new }.to raise_error CanCan::AccessDenied
      end
    end

    describe "POST #create" do
      it "should not allow a student to create an announcement" do
        expect { post :create, params: { announcement:
                                         { title: "New Tour", body: "Test" }}}.to \
          raise_error CanCan::AccessDenied
      end
    end
  end

  context "as a professor" do
    before(:each) do
      login_user(professor)
    end

    describe "GET #index" do
      let!(:non_course_announcement) { create :announcement }

      it "lists the announcements that are available for that course" do
        get :index
        expect(assigns(:announcements)).to eq [announcement]
      end

      it "does not list announcements that are for another recipient" do
        create :announcement, :for_recipient, course: course

        get :index

        expect(assigns(:announcements)).to eq [announcement]
      end
    end

    describe "POST #create" do
      let(:body) { Faker::Lorem.sentence(3) }

      context "with a successful announcement" do
        it "creates a new announcement" do
          post :create, params: { announcement: { title: "New Tour", body: body }}
          announcement = Announcement.unscoped.last
          expect(announcement.title).to eq "New Tour"
          expect(announcement.body).to eq body
          expect(announcement.course).to eq course
          expect(announcement.author).to eq professor
        end

        it "redirects back to the announcements page" do
          post :create, params: { announcement: { title: "New Tour", body: body }}
          expect(response).to redirect_to announcements_path
        end

        it "sends out the announcement to all the students in the course" do
          student = create :user, courses: [course], role: :student
          expect {
            post :create, params: { announcement: { title: "New Tour", body: body }}
          }.to change  { ActionMailer::Base.deliveries.count }.by 2
        end
      end

      context "with an invalid announcement" do
        it "renders view with the errors" do
          post :create, params: { announcement: { title: "", body: body }}
          expect(response).to render_template :new
        end
      end
    end
  end
end
