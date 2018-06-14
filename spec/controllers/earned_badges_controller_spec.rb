describe EarnedBadgesController do
  let(:course) { build :course }
  let(:professor) { create(:course_membership, :professor, course: course).user }
  let!(:student) { create(:course_membership, :student, course: course).user }
  let(:observer) { create(:user, courses: [course], role: :observer) }
  let(:badge) { create(:badge, course: course) }
  let!(:earned_badge) { create(:earned_badge, badge: badge, student: student) }
  let(:badge_student_awardable)  { create(:badge, course: course, student_awardable: true) }
  let(:other_student) { create(:user, courses: [course], role: :student) }

  context "as a professor" do
    before(:each) do
      login_user(professor)
    end

    describe "GET index" do
      it "redirects to the badge for the earned badge" do
        get :index, params: { badge_id: badge.id }
        expect(response).to redirect_to(badge_path(badge))
      end
    end

    describe "GET show" do
      it "returns the earned badge show page" do
        get :show, params: { id: earned_badge.id, badge_id: badge.id }
        expect(assigns(:earned_badge)).to eq(earned_badge)
        expect(response).to render_template(:show)
      end
    end

    describe "GET new" do
      it "display the create form" do
        get :new, params: { badge_id: badge.id }
        expect(assigns(:earned_badge)).to be_a_new(EarnedBadge)
        expect(response).to render_template(:new)
      end
    end

    describe "GET edit" do
      it "displays the edit form" do
        get :edit, params: { id: earned_badge.id, badge_id: badge.id }
        expect(assigns(:earned_badge)).to eq(earned_badge)
        expect(response).to render_template(:edit)
      end
    end

    describe "POST create" do
      it "creates the earned badge with valid attributes" do
        expect{ post :create, params: { badge_id: badge.id, earned_badge: { badge_id: badge.id,
                                        student_id: student.id,
                                        student_visible: true,
                                        feedback: "You did great!" }}}.to \
          change(EarnedBadge.student_visible, :count).by(1)
        expect(response).to redirect_to badge_path(badge)
      end

      it "doesn't create earned badges with invalid attributes" do
        expect{ post :create, params: { badge_id: badge.id, earned_badge: { badge_id: badge.id,
                                        student_id: nil,
                                        student_visible: true,
                                        feedback: "You rock!" }}}.to_not \
          change(EarnedBadge,:count)
      end
    end

    describe "POST mass_earn" do
      before(:all) do
        @students = create_list(:user, 2)
        @student_ids = @students.collect(&:id)
      end

      subject { post :mass_earn, params: { badge_id: badge[:id], student_ids: @student_ids }}

      context "earned badges are created" do
        before do
          @earned_badges = @students.collect do |student|
            create(:earned_badge, student_id: student[:id], badge: badge)
          end
        end

        it "redirects to the badge page" do
          allow(controller).to receive(:parse_valid_earned_badges) { @earned_badges }
          expect(subject).to redirect_to(badge_path(badge))
        end

        it "redirects back to the edit page" do
          allow(controller).to receive(:parse_valid_earned_badges) { [] }
          expect(subject).to redirect_to(mass_edit_badge_earned_badges_path(badge))
        end
      end
    end

    describe "send_earned_badge_notifications" do
      before(:all) do
        @students = create_list(:user, 2)
        @student_ids = @students.collect(&:id)
      end

      before(:each) do
        @earned_badges = @students.collect do |student|
          create(:earned_badge, student_id: student.id, badge: badge, awarded_by: professor)
        end
        @controller = EarnedBadgesController.new
      end

      context "earned badges exist" do
        before(:each) do
          @controller.instance_variable_set(:@valid_earned_badges, @earned_badges)
        end

        it "should send a notification" do
          mail_responder = double("earned badge mail responder!!")
          allow(mail_responder).to receive(:deliver_now)
          allow(NotificationMailer).to receive(:earned_badge_awarded) { mail_responder }
          @earned_badges.each do |earned_badge|
            expect(NotificationMailer).to receive(:earned_badge_awarded).with(earned_badge)
          end
          @controller.instance_eval { send_earned_badge_notifications }
        end

        it "should create an announcement" do
          expect { @controller.instance_eval { send_earned_badge_notifications }}.to \
            change { Announcement.count }.by 2
        end
      end

      context "no earned badges" do
        before { controller.instance_variable_set(:@valid_earned_badges, []) }

        it "should not send any notifications" do
          expect(NotificationMailer).not_to receive(:earned_badge_awarded)
          controller.instance_eval { send_earned_badge_notifications }
        end

        it "should not create any announcements" do
          expect { controller.instance_eval { send_earned_badge_notifications }}.to_not \
            change { Announcement.count }
        end
      end
    end

    describe "POST update" do
      it "updates the earned badge" do
        params = { badge_id: badge.id, student_id: student.id, feedback: "great!" }
        post :update, params: { id: earned_badge.id, badge_id: badge.id, earned_badge: params }
        expect(earned_badge.reload.feedback).to eq("great!")
        expect(response).to redirect_to(badge_path(badge))
      end

      it "renders the edit template if the update fails" do
        params = { badge_id: badge.id, student_id: nil, feedback: "great!" }
        post :update, params: { id: earned_badge.id, badge_id: badge.id, earned_badge: params }
        expect(response).to render_template(:edit)
      end
    end

    describe "GET mass_edit" do
      it "assigns params" do
        get :mass_edit, params: { badge_id: badge }
        expect(assigns(:badge)).to eq(badge)
        expect(assigns(:students)).to eq([student])
        expect(response).to render_template(:mass_edit)
      end

      describe "with teams" do
        it "assigns team and students for team" do
          # we verify only students on team assigned as students
          other_student = create(:user, courses: [course], role: :student)

          team = create(:team, course: course)
          team.students << student

          get :mass_edit, params: { badge_id: badge.id, team_id: team.id }
          expect(assigns(:team)).to eq(team)
          expect(assigns(:students)).to eq([student])
        end
      end

      describe "with no team id in params" do
        it "assigns all students if no team supplied" do
          # we verify non-team members also assigned as students
          other_student = create(:user, courses: [course], role: :student)

          get :mass_edit, params: { badge_id: badge.id }
          expect(assigns(:students)).to include(student)
          expect(assigns(:students)).to include(other_student)
        end
      end

      describe "when badges can be earned multiple times" do
        it "assigns earned badges according to alphabetized students" do
          student.update(last_name: "Zed")
          student2 = create(:user, last_name: "Alpha", courses: [course], role: :student)

          get :mass_edit, params: { badge_id: badge.id }
          expect(assigns(:earned_badges).count).to eq(2)
          expect(assigns(:earned_badges)[0].student_id).to eq(student2.id)
          expect(assigns(:earned_badges)[1].student_id).to eq(student.id)
        end

      end

      describe "when badges can only be earned once" do
        it "builds a new one if it hasn't been earned" do
          badge.can_earn_multiple_times = false
          badge.save

          get :mass_edit, params: { badge_id: badge.id }
          expect(assigns(:earned_badges)).to eq([earned_badge])
          expect(response).to render_template(:mass_edit)
        end
      end
    end

    describe "GET destroy" do
      it "destroys the earned badge" do
        expect{ get :destroy, params: { id: earned_badge, badge_id: badge.id } }.to change(EarnedBadge,:count).by(-1)
      end
    end
  end

  context "as student" do
    before(:each) do
      login_user(student)
    end

    describe "protected routes" do
      it "index redirects to root" do
        expect(get :index, params: {badge_id: badge.id}).to redirect_to(:root)
      end
    end

    describe "GET new" do
      it "display the create form when the badge is student-awardable" do
        get :new, params: { badge_id: badge_student_awardable.id }
        expect(assigns(:earned_badge)).to be_a_new(EarnedBadge)
        expect(response).to render_template(:new)
      end

      it "is forbidden when the badge is not student-awardable" do
        expect{get :new, params: {badge_id: badge.id}}.to raise_error CanCan::AccessDenied
      end
    end

    describe "POST create" do
      it "creates the earned badge when the badge is student-awardable" do
        expect{ post :create, params: { badge_id: badge_student_awardable.id, earned_badge: {
              badge_id: badge_student_awardable.id,
              student_id: other_student.id,
              student_visible: true,
              feedback: "You did great!"
            }}
          }.to change(EarnedBadge.student_visible, :count).by(1)
        expect(response).to redirect_to badge_path(badge_student_awardable)
      end

      it "doesn't create the student-awardable earned badge when the awardee and current user are the same" do
        expect{ post :create, params: { badge_id: badge_student_awardable.id, earned_badge: {
              badge_id: badge_student_awardable.id,
              student_id: student.id,
              student_visible: true,
              feedback: "You did great!"
            }}
          }.to_not change(EarnedBadge,:count)
          expect(flash[:alert]).to eq 'Permission denied'
      end

      it "doesn't create earned badge when the badge is not student-awardable" do
        expect{ post :create, params: { badge_id: badge.id, earned_badge: {
              badge_id: badge.id,
              student_id: student.id,
              student_visible: true,
              feedback: "You did great!"
            }}
          }.to_not change(EarnedBadge,:count)
          expect(flash[:alert]).to eq 'Permission denied'
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
          expect(get route, params: {badge_id: badge.id, id: "1"}).to redirect_to(:root)
        end
        it "#{route} redirects to root for student-awardable badges" do
          expect(get route, params: {badge_id: badge_student_awardable.id, id: "1"}).to redirect_to(:root)
        end
      end
    end
  end

  context "as an observer" do
    before(:each) { login_user(observer) }

    describe "protected routes not requiring id in params" do
      params = { badge_id: "1" }
      routes = [
        { action: :index, request_method: :get },
        { action: :create, request_method: :post },
        { action: :new, request_method: :get }
      ]
      routes.each do |route|
        it "#{route[:request_method]} :#{route[:action]} redirects to assignments index" do
          expect(eval("#{route[:request_method]} :#{route[:action]}, params: #{params}")).to \
            redirect_to(assignments_path)
        end
      end
    end

    describe "protected routes requiring id in params" do
      params = { badge_id: "1", id: "1" }
      routes = [
        { action: :edit, request_method: :get },
        { action: :show, request_method: :get },
        { action: :update, request_method: :post },
        { action: :destroy, request_method: :get }
      ]
      routes.each do |route|
        it "#{route[:request_method]} :#{route[:action]} redirects to assignments index" do
          expect(eval("#{route[:request_method]} :#{route[:action]}, params: #{params}")).to \
            redirect_to(assignments_path)
        end
      end
    end
  end
end
