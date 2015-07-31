require 'spec_helper'

describe EarnedBadgesController do

  context "as a professor" do
    before do
      @course = create(:course)
      @badge = create(:badge)
      @course.badges << @badge

      @student = create(:user)
      @student.courses << @course

      @team = create(:team, course: @course)
      @team.students << @student

      @earned_badge = create(:earned_badge, badge: @badge, student: @student)

      @professor = create(:user)
      @professor.courses << @course
      @membership = CourseMembership.where(user: @professor, course: @course).first.update(role: "professor")


      login_user(@professor)
      session[:course_id] = @course.id
      allow(EventLogger).to receive(:perform_async).and_return(true)
    end

    let(:valid_session) { { "current_course" => @course} }

    
    describe "GET index" do 
      it "redirects to the badge for the earned badge" do
        get :index, :badge_id => @badge.id
        response.should redirect_to(badge_path(@badge))
      end
    end

    describe "GET show" do 
      it "returns the earned badge show page" do
        get :show, { :id => @earned_badge.id, :badge_id => @badge.id }
        assigns(:title).should eq("#{@student.name}'s #{@badge.name} badge")
        assigns(:earned_badge).should eq(@earned_badge)
        response.should render_template(:show)
      end
    end

    describe "GET new" do 
      it "display the create form" do
        get :new, :badge_id => @badge.id
        assigns(:title).should eq("Award #{@badge.name}")
        assigns(:earned_badge).should be_a_new(EarnedBadge)
        response.should render_template(:new)
      end
    end

    describe "GET edit" do
      it "display the edit form" do
        get :edit, {:id => @earned_badge.id, :badge_id => @badge.id}
        assigns(:title).should eq("Editing Awarded #{@badge.name}")
        assigns(:earned_badge).should eq(@earned_badge)
        response.should render_template(:edit)
      end
    end

    describe "POST create" do
      it "creates the earned badge with valid attributes"  do
        pending
        params = { :id => @earned_badge.id }
        expect{ post :create, :badge_id => @badge.id, :earned_badge => params }.to change(EarnedBadge,:count).by(1)
      end

      it "doesn't create earned badges with invalid attributes" do
        pending
        expect{ post :create, earned_badge: attributes_for(:earned_badge, badge_id: @badge.id, student_id: nil) }.to_not change(EarnedBadge,:count)
      end
    end

    describe "POST update" do
      it "updates the earned badge" do
        params = { feedback: "more feedback" }
        post :update, { id: @earned_badge.id, :badge_id => @badge.id, :earned_badge => params }
        @earned_badge.reload
        @earned_badge.feedback.should eq("more feedback")
        response.should redirect_to(badge_path(@badge))
      end
    end

    describe "GET mass_edit" do
      it "assigns params" do
        get :mass_edit, :id => @badge.id
        assigns(:badge).should eq(@badge)
        assigns(:title).should eq("Quick Award #{@badge.name}")
        assigns(:students).should eq([@student])
        response.should render_template(:mass_edit)
      end

      describe "with teams" do
        pending
      end

      describe "when badges can be earned multiple times" do
        it "assigns earned badges according to alphabetized students" do
          @student.update(last_name: "Zed")
          @student2 = create(:user, last_name: "Alpha")
          @student2.courses << @course
          get :mass_edit, :id => @badge.id
          assigns(:earned_badges).count.should eq(2)
          assigns(:earned_badges)[0].student_id.should eq(@student2.id)
          assigns(:earned_badges)[1].student_id.should eq(@student.id)
        end
      end

      describe "when badges can only be earned once" do
        it "assigns earned badges..." do
          pending
        end
      end
    end


    describe "GET destroy" do
      it "destroys the earned badge" do
        expect{ get :destroy, { :id => @earned_badge, :badge_id => @badge.id } }.to change(EarnedBadge,:count).by(-1)
      end
    end
  end


  context "as student" do 

    describe "protected routes" do
      [
        :index,
        :new,
        :create

      ].each do |route|
          it "#{route} redirects to root" do
            pending
            (get route).should redirect_to(:root)
          end
        end
    end


    describe "protected routes requiring id in params" do
      [
        :edit,
        :show,
        :update,
        :destroy
      ].each do |route|
        it "#{route} redirects to root" do
          (get route, {:badge_id => 1, :id => "1"}).should redirect_to(:root)
        end
      end
    end

  end
end
