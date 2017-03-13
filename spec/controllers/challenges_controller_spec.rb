describe ChallengesController do
  let(:course) { build :course }
  let(:professor) { create(:course_membership, :professor, course: course).user }
  let(:student) { create(:course_membership, :student, course: course).user }
  let(:team) { create(:team, course: course) }
  let(:challenge) { create(:challenge, course: course) }
  let(:challenge_2) { create(:challenge, course: course) } 

  context "as professor" do
    before(:each) do
      team.students << student
      login_user(professor)
    end

    describe "GET index" do
      it "returns challenges for the current course" do
        get :index
        expect(assigns(:challenges)).to eq(course.reload.challenges)
        expect(response).to render_template(:index)
      end
    end

    describe "GET show" do
      it "returns the challenge show page" do
        get :show, params: { id: challenge.id }
        expect(assigns(:challenge)).to eq(challenge)
        expect(response).to render_template(:show)
      end
    end

    describe "GET new" do
      it "assigns title and challenge" do
        get :new
        expect(assigns(:challenge)).to be_a_new(Challenge)
        expect(response).to render_template(:new)
      end
    end

    describe "GET edit" do
      it "assigns the challenge and title" do
        get :edit, params: { id: challenge.id }
        expect(assigns(:challenge)).to eq(challenge)
        expect(response).to render_template(:edit)
      end
    end

    describe "POST create" do
      it "creates the challenge with valid attributes"  do
        params = attributes_for(:challenge)
        params[:challenge_id] = challenge
        expect{ post :create, params: { challenge: params }}.to \
          change(Challenge,:count).by(1)
      end

      it "manages file uploads" do
        Challenge.delete_all
        params = attributes_for(:challenge)
        params[:challenge_id] = challenge
        params.merge! challenge_files_attributes: {"0" => {"file" => [fixture_file("test_file.txt", "txt")]}}
        post :create, params: { challenge: params }
        challenge = Challenge.where(name: params[:name]).last
        expect expect(challenge.challenge_files.count).to eq(1)
      end

      it "redirects to new from with invalid attributes" do
        expect{ post :create, params: { challenge: attributes_for(:challenge, name: nil) }}
          .to_not change(Challenge,:count)
      end
    end

    describe "POST update" do
      it "updates the challenge" do
        params = { name: "new name" }
        post :update, params: { id: challenge_2.id, challenge: params }
        expect(response).to redirect_to(challenges_path)
        expect(challenge_2.reload.name).to eq("new name")
      end

      it "redirects to the edit form if the update fails" do
        params = { name: nil }
        post :update, params: { id: challenge_2.id, challenge: params }
        expect(response).to render_template(:edit)
      end

      it "manages file uploads" do
        params = {challenge_files_attributes: {"0" => {"file" => [fixture_file("test_file.txt", "txt")]}}}
        post :update, params: { id: challenge_2.id, challenge: params }
        expect expect(challenge_2.challenge_files.count).to eq(1)
      end
    end

    describe "GET destroy" do
      it "destroys the challenge" do
        another_challenge = create :challenge, course: course
        expect{ get :destroy, params: { id: another_challenge }}.to \
          change(Challenge,:count).by(-1)
      end
    end
  end

  context "as student" do
    before(:each) { login_user(student) }

    describe "protected routes" do
      [
        :new,
        :create
      ].each do |route|
          it "#{route} redirects to root" do
            expect(get route).to redirect_to(:root)
          end
        end
    end

    describe "protected routes requiring id in params" do
      [
        :edit,
        :update,
        :destroy
      ].each do |route|
        it "#{route} redirects to root" do
          expect(get route, params: { id: challenge.id }).to redirect_to(:root)
        end
      end
    end
  end

  # helper methods:

  def predictor_challenge_attributes
    [
      :id,
      :name,
      :description,
      :full_points,
      :visible
    ]
  end
end
