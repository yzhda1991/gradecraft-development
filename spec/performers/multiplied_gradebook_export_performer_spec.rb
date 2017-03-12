RSpec.describe MultipliedGradebookExportPerformer, type: :background_job do

  let(:course) { create(:course) }
  let(:user) { create(:user) }
  let(:attrs) {{ user_id: user[:id], course_id: course[:id] }}
  let(:performer) { MultipliedGradebookExportPerformer.new(attrs) }
  subject { performer }

  describe "methods inherited from GradeBookExportPerformer" do

    describe "setup" do
      it "should fetch the user and set it to user" do
        expect(subject).to receive(:fetch_user).and_return user
        subject.setup
        expect(subject.instance_variable_get(:@user)).to eq(user)
      end

      it "should fetch the course and set it to course" do
        expect(subject).to receive(:fetch_course).and_return course
        subject.setup
        expect(subject.instance_variable_get(:@course)).to eq(course)
      end
    end

    describe "do_the_work" do
      context "both course and user present" do
        after(:each) do
          subject.do_the_work
        end

        it "should require success" do
          expect(subject).to receive(:require_success).exactly(2).times
        end

        it "should add an outcome to subject.outcomes" do
          expect { subject.do_the_work }.to change { subject.outcomes.size }.by(2)
        end

        it "should fetch the csv data" do
          allow(subject).to receive(:fetch_csv_data).with(course).and_return "some,csv,data"
          expect(subject).to receive(:fetch_csv_data).with(course)
        end

        it "should mail notification that the gradebook was exported" do
          expect(subject).to receive(:notify_gradebook_export)
        end

        it "should return the result of notify_gradebook_export" do
          @export_result = double(:export_result)
          allow(subject).to receive_messages(notify_gradebook_export: @export_result)
          allow(subject).to receive(:fetch_csv_data).with(course).and_return "some,csv,data"
          expect(subject).to receive(:require_success).and_return(@export_result)
          expect(subject).to receive(:require_success).and_return("some,csv,data")
        end

        describe "require_success" do
          describe "notify_gradebook_export requirement" do
            context "block outcome fails" do
              it "should add the :success outcome message to @outcome_messages" do
                allow(subject).to receive_messages(notify_gradebook_export: true)
                subject.do_the_work
                expect(subject.outcome_messages.last).to match("was successfully delivered")
              end
            end

            context "block outcome succeeds" do
              it "should add the :failure outcome message to @outcome_messages" do
                allow(subject).to receive_messages(notify_gradebook_export: false)
                subject.do_the_work
                expect(subject.outcome_messages.last).to match("was not delivered")
              end
            end
          end
        end
      end

      context "either course or user are not present" do
        # omit subject.setup so user and course are nil
        before(:each) do
          subject.remove_instance_variable(:@course)
          subject.remove_instance_variable(:@user)
        end

        it "should not require success" do
          expect(subject).not_to receive(:require_success)
          subject.do_the_work
        end

        it "should return nil" do
          expect(subject.do_the_work).to eq(nil)
        end
      end
    end
  end
end
