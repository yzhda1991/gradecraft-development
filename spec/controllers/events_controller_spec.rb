describe EventsController do
  let(:course) { build(:course) }
  let(:event) { create(:event, course: course) }
  let(:professor) { create(:course_membership, :professor, course: course).user }
  let(:student) { create(:course_membership, :student, course: course).user }

  context "as a professor" do
    before(:each) do
      login_user(professor)
    end

    describe "GET index" do
      it "assigns all events as events" do
        get :index
        expect(assigns(:events)).to eq([event])
      end
    end

    describe "GET show" do
      it "assigns the requested event as event" do
        get :show, params: { id: event.to_param }
        expect(assigns(:event)).to eq(event)
      end
    end

    describe "GET new" do
      it "assigns a new event as @event" do
        get :new
        expect(assigns(:event)).to be_a_new(Event)
      end
    end

    describe "GET edit" do
      it "assigns the requested event as event" do
        get :edit, params: { id: event.to_param }
        expect(assigns(:event)).to eq(event)
      end
    end

    describe "POST create" do
      describe "with valid params" do
        it "creates a new Event" do
          params = attributes_for(:event)
          expect{ post :create, params: { event: params }}.to change(Event,:count).by(1)
        end

        it "assigns a newly created event as event" do
          params = attributes_for(:event)
          post :create, params: { event: params }
          expect(assigns(:event)).to be_a(Event)
          expect(assigns(:event)).to be_persisted
        end

        it "redirects to the created event" do
          params = attributes_for(:event)
          post :create, params: { event: params }
          expect(response).to redirect_to(Event.last)
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved event as event" do
          allow_any_instance_of(Event).to receive(:save).and_return(false)
          post :create, params: { event: { "name" => nil }}
          expect(assigns(:event)).to be_a_new(Event)
        end

        it "should not increase the Event count" do
          expect{ post :create, params: { event: attributes_for(:event, name: nil) }}.to_not change(Event,:count)
        end
      end
    end

    describe "PUT update" do
      describe "with valid params" do
        it "updates the requested event" do
          params = { name: "new name" }
          put :update, params: { id: event.id, event: params }
          expect(response).to redirect_to(event_path(event))
          expect(event.reload.name).to eq("new name")
        end
      end
    end

    describe "DELETE destroy" do
      it "destroys the requested event" do
        event
        expect{ get :destroy, params: { id: event } }.to change(Event,:count).by(-1)
        expect(response).to redirect_to(events_url)
      end
    end

    describe "POST copy" do
      it "duplicates the requested event" do
        event
        post :copy, params: { id: event.id }
        expect expect(course.events.count).to eq(2)
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
        :destroy,
        :copy
      ].each do |route|
        it "#{route} redirects to root" do
          expect(get route, params: { id: "1" }).to redirect_to(:root)
        end
      end
    end
  end
end
