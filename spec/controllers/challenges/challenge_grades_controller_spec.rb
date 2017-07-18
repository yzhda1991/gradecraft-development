describe Challenges::ChallengeGradesController do
  let(:course) { create :course }
  let(:professor) { create(:course_membership, :professor, course: course).user }
  let(:student) { create(:course_membership, :student, course: course).user }
  let(:team) { create(:team, course: course) }
  let(:challenge) { create(:challenge, course: course) }
  let(:challenge_grade) { create(:challenge_grade, team: team, challenge: challenge) }

  context "as professor" do
    before(:each) do
      login_user(professor)
    end

    describe "GET new" do
      it "shows the new challenge grade form" do
        get :new, params: { challenge_id: challenge, team_id: team }
        expect(assigns(:challenge)).to eq(challenge)
        expect(assigns(:team)).to eq(team)
        expect(response).to render_template(:new)
      end
    end

    describe "POST create" do
      it "creates the challenge grade with valid attributes and redirects to the challenge show page" do
        team2 = create(:team, course: course )
        params = attributes_for(:challenge_grade)
        params[:raw_points] = "101"
        params[:challenge_id] = challenge.id
        params[:team_id] = team2.id
        params[:complete] = true
        params[:student_visible] = true
        post :create, params: { challenge_id: challenge.id, challenge_grade: params }
        grade = challenge.challenge_grades.where(:team_id => team2.id).first
        expect(grade.score).to eq 101
        expect(grade.instructor_modified).to be_truthy
        expect(response).to redirect_to(challenge)
      end

      it "redirects to new form with invalid attributes" do
        expect{ post :create,
                params: { challenge_id: challenge.id,
                          challenge_grade: attributes_for(:challenge_grade, team_id: nil) }}
          .to_not change(ChallengeGrade,:count)
      end
    end


    describe "GET mass_edit" do
      it "assigns params" do
        get :mass_edit, params: { challenge_id: challenge.id }
        expect(response).to render_template(:mass_edit)
      end
    end

    describe "POST mass_update" do
      it "updates the challenge grades for the specific challenge" do
        challenge_grades_attributes = { "0" =>
          { team_id: team.id, student_visible: true, raw_points: 1000, id: challenge_grade.id }
        }
        put :mass_update, params: { challenge_id: challenge.id,
          challenge: { challenge_grades_attributes: challenge_grades_attributes }}
        expect(challenge_grade.reload.score).to eq 1000
      end

      it "redirects to the mass_edit form if attributes are invalid" do
        challenge_grades_attributes = { "0" =>
          { team_id: nil, raw_points: 1000, student_visible: true, id: challenge_grade.id }
        }
        put :mass_update, params: { challenge_id: challenge.id,
          challenge: { challenge_grades_attributes: challenge_grades_attributes }}
        expect(response).to render_template(:mass_edit)
      end
    end

    describe "PUT release" do
      it "updates the status of multiple challenge grades" do
        put :release, params: { challenge_id: challenge.id, challenge_grade_ids: [ challenge_grade.id ] }
        expect(challenge_grade.reload.instructor_modified).to be_truthy
        expect(challenge_grade.complete).to be_truthy
        expect(challenge_grade.student_visible).to be_truthy
        expect(response).to redirect_to challenge_path(challenge)
      end
    end
  end

  context "as student" do
    describe "protected routes" do
      [
        :new,
        :create
      ].each do |route|
          it "#{route} redirects to root" do
            expect(get route, params: { challenge_id: 2 }).to redirect_to(:root)
          end
        end
    end

    describe "protected routes requiring id in params" do
    [
      :mass_edit,
      :mass_update,
      :release
    ].each do |route|
        it "#{route} redirects to root" do
          expect(get route, params: { challenge_id: 2, id: "1" }).to redirect_to(:root)
        end
      end
    end
  end
end
