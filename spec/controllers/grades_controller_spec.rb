require 'rails_spec_helper'

describe GradesController do
  include PredictorEventJobsToolkit

  before(:all) do
    @course = create(:course)
    @assignment = create(:assignment, course: @course)
    @student = create(:user)
    @student.courses << @course
  end
  before(:each) do
    allow(Resque).to receive(:enqueue).and_return(true)
  end


  context "as professor" do
    before(:all) do
      @professor = create(:user)
      CourseMembership.create user: @professor, course: @course, role: "professor"
    end

    before (:each) do
      @grade = create(:grade, student: @student, assignment: @assignment, course: @course)
      login_user(@professor)
    end

    after(:each) do
      @grade.delete
    end

    describe "GET show" do

      context "for a group grade" do
        it "assigns group, title, and grades for assignment when assignment has groups" do
          course = create(:course_accepting_groups)
          group = create(:group, course: course)
          assignment = group.assignments.first
          course.assignments << assignment
          student = create(:user)
          student.courses << course
          group.students << student
          grade = create(:grade, group: group, assignment: assignment, course: course, :student_id => @student.id)
          allow(controller).to receive(:current_course).and_return(course)
          get :show, { :id => grade.id, :assignment_id => assignment.id, :student_id => student.id, :group_id => group.id }

          expect(assigns(:assignment)).to eq(assignment)
          expect(assigns(:group)).to eq(group)
          expect(assigns(:title)).to eq("#{group.name}'s Grade for #{assignment.name}")
          expect(assigns(:grades_for_assignment)).to eq(assignment.grades.graded_or_released)
          expect(response).to render_template(:show)
        end
      end

      it "assigns the assignment, title and grades for assignment" do
        get :show, { :id => @grade.id, :assignment_id => @assignment.id, :student_id => @student.id }
        expect(assigns(:assignment)).to eq(@assignment)
        expect(assigns(:title)).to eq("#{@student.name}'s Grade for #{@assignment.name}")
        expect(assigns(:grades_for_assignment)).to eq(@assignment.grades_for_assignment(@student))
        expect(response).to render_template(:show)
      end

      it "assigns the rubric and metrics for individual assignments" do
        assignment = create(:assignment, course: @course)
        rubric = create(:rubric_with_metrics, assignment: assignment)
        metric = rubric.metrics.first
        tier = rubric.metrics.first.tiers.first
        rubric_grade = create(:rubric_grade, assignment: assignment, student: @student, metric: metric, tier: tier)
        get :show, { :id => @grade.id, :assignment_id => assignment.id, :student_id => @student.id }
        expect(assigns(:rubric)).to eq(rubric)
        expect(assigns(:metrics)).to eq(rubric.metrics)
        expect(JSON.parse(assigns(:rubric_grades))).to eq([{ "id" => rubric_grade.id, "metric_id" => metric.id, "tier_id" => tier.id, "comments" => nil }])
      end
    end

    describe "GET edit" do

      it "creates a grade if none present" do
        assignment = create(:assignment, course: @course)
        expect{get :edit, { :assignment_id => assignment.id, :student_id => @student.id }}.to change{Grade.count}.by(1)
      end

      it "assigns grade parameters and renders edit" do
        get :edit, { :assignment_id => @assignment.id, :student_id => @student.id }
        expect(assigns(:assignment)).to eq(@assignment)
        expect(assigns(:student)).to eq(@student)
        expect(assigns(:grade)).to eq(@grade)
        expect(assigns(:title)).to eq("Editing #{@student.name}'s Grade for #{@assignment.name}")
        expect(response).to render_template(:edit)
      end

      context "with additional grade items" do
        it "assigns existing submissions, badges and score levels" do
          assignment = create(:assignment, course: @course)
          submission = create(:submission, student: @student, assignment: assignment)
          badge = create(:badge, course: @course)
          score_level = create(:assignment_score_level, assignment: assignment)

          get :edit, { :assignment_id => assignment.id, :student_id => @student.id }
          expect(assigns(:submission)).to eq(submission)
          expect(assigns(:badges)).to eq([badge])
          expect(assigns(:assignment_score_levels)).to eq([score_level])
        end
      end

      it "assigns json values for angular use" do
        get :edit, { :assignment_id => @assignment.id, :student_id => @student.id }
        json = JSON.parse(assigns(:serialized_init_data))
        expect(json).to have_key("grade")
        expect(json).to have_key("badges")
        expect(json).to have_key("assignment")
        expect(json).to have_key("assignment_score_levels")
      end

      it "if rubric present, assigns the rubric and rubric grades" do
        allow(request).to receive(:referer).and_return('http://gradecraft.com/assignments/123')
        assignment = create(:assignment, course: @course)
        rubric = create(:rubric_with_metrics, assignment: assignment)
        metric = rubric.metrics.first
        tier = rubric.metrics.first.tiers.first
        rubric_grade = create(:rubric_grade, assignment: assignment, student: @student, metric: metric, tier: tier)
        get :edit, { :id => @grade.id, :assignment_id => assignment.id, :student_id => @student.id }
        expect(assigns(:rubric)).to eq(rubric)
        expect(JSON.parse(assigns(:rubric_grades))).to eq([{ "id" => rubric_grade.id, "metric_id" => metric.id, "tier_id" => tier.id, "comments" => nil }])
        expect(assigns(:return_path)).to eq('/assignments/123')
      end
    end

    describe "POST update" do

      it "creates a grade if none present" do
        assignment = create(:assignment, course: @course)
        grade_params = { raw_score: 12345, assignment_id: assignment.id }
        expect{post :update, { :assignment_id => assignment.id, :student_id => @student.id, :grade => grade_params}}.to change{Grade.count}.by(1)
      end

      it "updates the grade" do
        grade_params = { raw_score: 12345, assignment_id: @assignment.id }
        post :update, { :assignment_id => @assignment.id, :student_id => @student.id, :grade => grade_params}
        @grade.reload
        expect(response).to redirect_to(assignment_path(@grade.assignment))
        expect(@grade.score).to eq(12345)
      end

      it "handles a grade file upload" do
        grade_params = { raw_score: 12345, assignment_id: @assignment.id, "grade_files_attributes"=> {"0"=>{"file"=>[fixture_file('Too long, strange characters, and Spaces (In) Name.jpg', 'img/jpg')]}}}
        post :update, { :assignment_id => @assignment.id, :student_id => @student.id, :grade => grade_params}
        expect(GradeFile.last.grade_id).to eq(@grade.id)
      end

      it "handles commas in raw score params" do
        grade_params = { raw_score: "12,345", assignment_id: @assignment.id }
        post :update, { :assignment_id => @assignment.id, :student_id => @student.id, :grade => grade_params}
        @grade.reload
        expect(response).to redirect_to(assignment_path(@grade.assignment))
        expect(@grade.score).to eq(12345)
      end

      it "handles reverting nil raw score" do
        grade_params = { raw_score: nil, assignment_id: @assignment.id }
        post :update, { :assignment_id => @assignment.id, :student_id => @student.id, :grade => grade_params}
        @grade.reload
        expect(response).to redirect_to(assignment_path(@grade.assignment))
        expect(@grade.score).to eq(nil)
      end

      it "reverts empty raw score to nil, not zero" do
        grade_params = { raw_score: "", assignment_id: @assignment.id }
        post :update, { :assignment_id => @assignment.id, :student_id => @student.id, :grade => grade_params}
        @grade.reload
        expect(response).to redirect_to(assignment_path(@grade.assignment))
        expect(@grade.score).to eq(nil)
      end

      it "returns to session if present" do
        session[:return_to] = login_path
        grade_params = { raw_score: 12345, assignment_id: @assignment.id }
        post :update, { :assignment_id => @assignment.id, :student_id => @student.id, :grade => grade_params}
        expect(response).to redirect_to(login_path)
      end

      it "redirects on failure" do
        allow_any_instance_of(Grade).to receive(:update_attributes).and_return false
        post :update, { :assignment_id => @assignment.id, :student_id => @student.id, :grade => {}}
        expect(response).to redirect_to(edit_assignment_grade_path(@assignment.id, :student_id => @student.id))
      end
    end

    describe "async_update" do

      it "updates feedback, status and raw score from params" do
        post :async_update, { id: @grade.id, raw_score: 20000, feedback: "good jorb!", status: "Graded" }
        @grade.reload
        expect(@grade.feedback).to eq("good jorb!")
        expect(@grade.status).to eq("Graded")
        expect(@grade.raw_score).to eq(20000)
      end

      it "updates instructor modified to true" do
        post :async_update, { id: @grade.id, raw_score: 20000, feedback: "good jorb!" }
        @grade.reload
        expect(@grade.instructor_modified).to be_truthy
      end

      describe "manages update with model validations" do
        it "handles commas in raw score params" do
          post :async_update, { id: @grade.id, raw_score: "12,345", feedback: "good jorb!" }
          @grade.reload
          expect(@grade.score).to eq(12345)
        end

        it "handles reverting nil raw score" do
          post :async_update, { id: @grade.id, raw_score: nil, feedback: "good jorb!" }
          @grade.reload
          expect(@grade.score).to eq(nil)
        end

        it "reverts empty raw score to nil, not zero" do
          post :async_update, { id: @grade.id, raw_score: "", feedback: "good jorb!" }
          @grade.reload
          expect(@grade.score).to eq(nil)
        end
      end
    end

    describe "earn_student_badge" do
      it "creates a new student badge from params" do
        badge = create(:badge)
        params = { earned_badge: { badge_id: badge.id, student_id: @student } }
        expect{post :earn_student_badge, params}.to change {EarnedBadge.count}.by(1)
      end
    end

    describe "earn_student_badges" do
      it "creates new student badges from params" do
        badge_1 = create(:badge)
        badge_2 = create(:badge)
        badge_3 = create(:badge)
        params = {grade_id: @grade.id, earned_badges: [{ badge_id: badge_1.id, student_id: @student },
                                  { badge_id: badge_2.id, student_id: @student },
                                  { badge_id: badge_3.id, student_id: @student }]}
        expect{post :earn_student_badges, params}.to change {EarnedBadge.count}.by(3)
      end
    end

    describe "delete_all_earned_badges"  do
      it "destroys all earned badges for grade" do
        earned_badge_1 = create(:earned_badge, grade: @grade)
        earned_badge_2 = create(:earned_badge, grade: @grade)
        expect{ delete :delete_all_earned_badges, grade_id: @grade.id }.to change {EarnedBadge.count}.by(-2)
        expect(JSON.parse(response.body)).to eq({"message"=>"Earned badges successfully deleted", "success"=>true})
      end

      it "renders error if no badges found to delete" do
        delete :delete_all_earned_badges, {grade_id: @grade.id}
        expect(JSON.parse(response.body)).to eq({"message"=>"Earned badges failed to delete", "success"=>false})
      end
    end

    describe "delete_earned_badge" do

      it "deletes a badge when parameters include id, student id, badge id, and grade id" do
        earned_badge = create(:earned_badge, grade: @grade, student: @student)
        params = {grade_id: @grade.id, student_id: @student.id, badge_id: earned_badge.badge.id, id: earned_badge.id }
        expect{ delete :delete_earned_badge, params }.to change {EarnedBadge.count}.by(-1)
        expect(JSON.parse(response.body)).to eq({"message"=>"Earned badge successfully deleted", "success"=>true})
      end

      it "renders error if no badge found to delete" do
        params = {grade_id: @grade.id, student_id: @student.id, badge_id: 1, id: 1234 }
        delete :delete_earned_badge, params
        expect(JSON.parse(response.body)).to eq({"message"=>"Earned badge failed to delete", "success"=>false})
      end
    end

    describe "PUT submit_rubric" do

      before do
        @rubric_assignment = create(:assignment, course: @course)
        @rubric = create(:rubric_with_metrics, assignment: @rubric_assignment)
        @params = {assignment_id: @rubric_assignment.id, student_id: @student.id,  format: :json }
        @params[:rubric_grades] = @rubric.metrics.collect { |metric| { "metric_id" => metric.id, "metric_name" => metric.name, "order" => metric.order, "max_points"=> metric.max_points, "tier_id" => metric.tiers.first.id }}

        allow(controller).to receive(:current_student).and_return(@student)
      end

      it "updates the submission grading status" do
        submission = create(:submission, student: @student, assignment: @rubric_assignment)
        expect{ post :submit_rubric, @params }.to change { RubricGrade.count }.by(@rubric.metrics.count)
      end

      describe "finds or creates the grade for the assignment and student" do
        it "finds and assigns the grade" do
          grade = create(:grade, assignment: @rubric_assignment, student: @student)
          post :submit_rubric, @params
          expect(assigns(:grade)).to eq(grade)
        end

        it "cretes and assigns the grade" do
          expect{ post :submit_rubric, @params }.to change { Grade.count }.by(1)
          expect(assigns(:grade).assignment).to eq(@rubric_assignment)
          expect(assigns(:grade).student).to eq(@student)
        end
      end

      describe "when an additional `metric_ids` parameter is supplied" do

        before do
          @params[:metric_ids] = @rubric.metrics.collect { |metric| metric.id }
        end

        it "deletes all preexisting rubric grades" do
          expect{ post :submit_rubric, @params }.to change { RubricGrade.count }.by(6)
          expect{ post :submit_rubric, @params }.to change { RubricGrade.count }.by(0)
        end

        it "deletes existing earned badges" do
          earned_badge = create(:earned_badge, student: @student, metric_id: @rubric.metrics.first.id )
          allow(controller).to receive(:current_student).and_return(@student)
          expect{ post :submit_rubric, @params }.to change { EarnedBadge.count }.by(-1)
        end
      end

      it "creates the rubric grades" do
        allow(controller).to receive(:current_student).and_return(@student)
        expect{ post :submit_rubric, @params }.to change { RubricGrade.count }.by(@rubric.metrics.count)
      end

      it "adds earned tier badges" do
        earnable_badge = create(:badge, course: @course)
        tier_badge = TierBadge.create(badge: earnable_badge, tier: @rubric.metrics.first.tiers.first.id )
        @params[:tier_badges] = [{badge_id: earnable_badge.id, tier_badge: tier_badge.id, tier_id: @rubric.metrics.first.tiers.first.id}]
        expect{ post :submit_rubric, @params }.to change { EarnedBadge.count }.by(1)
      end

      it "renders nothing when request format is JSON" do
        post :submit_rubric, @params
        expect(response.body).to eq("")
      end
    end

    describe "GET mass_edit" do
      it "assigns params" do
        get :mass_edit, :id => @assignment.id
        expect(assigns(:title)).to eq("Quick Grade #{@assignment.name}")
        expect(response).to render_template(:mass_edit)
      end
    end

    describe "PUT mass_update" do

      let(:grades_attributes) do
        { "#{@assignment.grades.index(@grade)}" =>
          { graded_by_id: @professor.id, instructor_modified: true,
            student_id: @grade.student_id, raw_score: 1000, status: "Graded",
            id: @grade.id
          }
        }
      end

      it "updates the grades for the specific assignment" do
        put :mass_update, id: @assignment.id, assignment: { grades_attributes: grades_attributes }
        expect(@grade.reload.raw_score).to eq 1000
      end

      it "sends a notification to the student to inform them of a new grade" do
        pending "fix this later, needs to account for the job sending the mailer"
        run_resque_inline do
          expect { put :mass_update, id: @assignment.id, assignment: { grades_attributes: grades_attributes } }.to \
            change { ActionMailer::Base.deliveries.count }.by 1
        end
      end

      it "only sends notifications to the students if the grade changed" do
        @grade.update_attributes({ raw_score: 1000 })
        run_background_jobs_immediately do
          expect { put :mass_update, id: @assignment.id, assignment: { grades_attributes: grades_attributes } }.to_not \
            change { ActionMailer::Base.deliveries.count }
        end
      end
    end

    describe "GET group_edit" do
      it "assigns params" do
        group = create(:group)
        @assignment.groups << group
        group.students << @student
        get :group_edit, { :id => @assignment.id, :group_id => group.id}
        expect(assigns(:title)).to eq("Grading #{group.name}'s #{@assignment.name}")
        expect(response).to render_template(:group_edit)
      end
    end

    describe "GET edit_status" do
      it "displays the edit status page" do
        get :edit_status, {:grade_ids => [@grade.id], :id => @assignment.id}
        expect(assigns(:title)).to eq("#{@assignment.name} Grade Statuses")
        expect(response).to render_template(:edit_status)
      end
    end

    describe "GET import" do
      it "displays the import page" do
        get :import, { :id => @assignment.id}
        expect(assigns(:title)).to eq("Import Grades for #{@assignment.name}")
        expect(response).to render_template(:import)
      end
    end

    describe "POST upload" do
      render_views

      let(:file) { fixture_file "grades.csv", "text/csv" }

      it "renders the results from the import" do
        @student.reload.update_attribute :email, "robert@example.com"
        second_student = create(:user, username: "jimmy")
        second_student.courses << @course

        post :upload, id: @assignment.id, file: file
        expect(response).to render_template :import_results
        expect(response.body).to include "2 Grades Imported Successfully"
      end

      it "renders any errors that have occured" do
        post :upload, id: @assignment.id, file: file
        expect(response.body).to include "3 Grades Not Imported"
        expect(response.body).to include "Student not found in course"
      end
    end
  end

  context "as student" do
    before do
      @grade = create(:grade, student: @student, assignment: @assignment, course: @course)
      login_user(@student)
      allow(controller).to receive(:current_student).and_return(@student)
    end

    after(:each) do
      @grade.delete
    end

    describe "GET show" do
      it "redirects to the assignment" do
        get :show, {:grade_id => @grade.id, :assignment_id => @assignment.id}
        expect(response).to redirect_to(assignment_path(@assignment))
      end
    end

    describe "POST predict_score" do
      let(:predicted_points) { (@assignment.point_total * 0.75).to_i }

      it "updates the predicted score for an assignment" do
        get :predict_score, { :id => @assignment.id, predicted_score: predicted_points, format: :json }
        @grade.reload
        expect(@grade.predicted_score).to eq(predicted_points)
        expect(JSON.parse(response.body)).to eq({"id" => @assignment.id, "points_earned" => predicted_points})
      end

      it "enqueues_the_predictor_event_job" do
        expect(controller).to receive(:enqueue_predictor_event_job)
        get :predict_score, { :id => @assignment.id, predicted_score: predicted_points, format: :json }
      end
    end

    describe "enqueue_predictor_event_job" do
      context "Resque connects to redis and enqueues the damn job" do
        before(:each) do
          @predictor_event_job = double(:predictor_event_job)
          @enqueue_response = double(:enqueue_response)
          allow(@predictor_event_job).to receive(:enqueue)
          allow(PredictorEventJob).to receive_messages(new: @predictor_event_job)
          allow(controller).to receive(:predictor_event_attrs) { predictor_event_attrs_expectation }
        end

        it "should create a new pageview logger" do
          expect(PredictorEventJob).to receive(:new).with(data: predictor_event_attrs_expectation)
        end

        it "should enqueue the new pageview logger in 2 hours" do
          expect(@predictor_event_job).to receive(:enqueue) { @enqueue_response }
        end

        after(:each) do
          controller.instance_eval { enqueue_predictor_event_job }
        end
      end

      context "Resque fails to reach Redis and returns a getaddrinfo socket error" do
        before do
          allow(PredictorEventJob).to receive_message_chain(:new, :enqueue).and_raise("MOCK FAUX LAME NONERROR: Could not connect to Redis: getaddrinfo socket error.")
          allow(controller).to receive(:predictor_event_attrs) { predictor_event_attrs_expectation }
        end

        it "performs the pageview event log directly from the controller" do
          expect(PredictorEventJob).to receive(:perform).with(data: predictor_event_attrs_expectation)
          controller.instance_eval { enqueue_predictor_event_job }
        end

        it "adds an additional pageview record to mongo" do
          expect {
            controller.instance_eval { enqueue_predictor_event_job }
          }.to change{ Analytics::Event.count }.by(1)
        end
      end
    end

    describe "POST feedback_read" do
      it "marks the grade as read by the student" do
        post :feedback_read, id: @assignment.id, grade_id: @grade.id
        expect(response).to redirect_to assignment_path(@assignment)
        expect(@grade.reload).to be_feedback_read
      end
    end

    describe "POST self_log" do
      it "creates a maximum score by the student" do
        post :self_log, id: @assignment.id, present: "true"
        grade = @student.grade_for_assignment(@assignment)
        expect(grade.raw_score).to eq @assignment.point_total
      end

      context "with assignment levels" do
        it "creates a score for the student at the specified level" do
          post :self_log, id: @assignment.id, present: "true", grade: { raw_score: "10000" }
          grade = @student.grade_for_assignment(@assignment)
          expect(grade.raw_score).to eq 10000
        end
      end
    end

    describe "protected routes" do
      before(:all) do
        @group = create(:group)
        @assignment.groups << @group
      end

      it "all redirect to root" do
        [ Proc.new { get :edit, {:grade_id => @grade.id, :assignment_id => @assignment.id }},
          Proc.new { get :update, {:grade_id => @grade.id, :assignment_id => @assignment.id }},
          Proc.new { get :edit, {:grade_id => @grade.id, :assignment_id => @assignment.id }},
          Proc.new { get :update, {:grade_id => @grade.id, :assignment_id => @assignment.id }},
          Proc.new { get :submit_rubric, {:grade_id => @grade.id, :assignment_id => @assignment.id }},
          Proc.new { get :remove, { :id => @assignment.id, :grade_id => @grade.id }},
          Proc.new { delete :destroy, {:grade_id => @grade.id, :assignment_id => @assignment.id }},
          Proc.new { get :mass_edit, { :id => @assignment.id  }},
          Proc.new { post :mass_update, { :id => @assignment.id }},
          Proc.new { get :group_edit, { :id => @assignment.id, :group_id => @group.id }},
          Proc.new { post :group_update, { :id => @assignment.id, :group_id => @group.id }},
          Proc.new { get :edit_status, {:grade_ids => [@grade.id], :id => @assignment.id }},
          Proc.new { post :update_status, {:grade_ids => @grade.id, :id => @assignment.id }},
          Proc.new { get :import, { :id => @assignment.id }},
          Proc.new { post :upload, { :id => @assignment.id }},
        ].each do |protected_route|
          expect(protected_route.call).to redirect_to(:root)
        end
      end
    end
  end
end
