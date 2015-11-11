require 'rails_spec_helper'

RSpec.describe AssignmentExportPerformer, type: :background_job do
  include PerformerToolkit::SharedExamples
  include ModelAddons::SharedExamples

  # public methods
  let(:professor) { create(:user) }
  let(:assignment) { create(:assignment) }
  let(:team) { create(:team) }

  let(:job_attrs) {{ professor_id: professor.id, assignment_id: assignment[:id], team_id: team[:id] }}
  let(:performer) { AssignmentExportPerformer.new(job_attrs) }
  subject { performer }

  it_behaves_like "ModelAddons::ImprovedLogging is included"

  describe "public methods" do

    describe "cache_assets", focus: true do
    subject { performer.instance_eval { fetch_assets }}

      it_behaves_like "a cacheable resource", :professor, User # this is a User object fetched as 'professor'
      it_behaves_like "a cacheable resource", :team
      it_behaves_like "a cacheable resource", :assignment
      it_behaves_like "a cacheable resource", :students, User # this is a User object fetched as 'student'
    end

    describe "do_the_work" do
      context "both course and user present" do
        after(:each) do
          subject.do_the_work
        end

        it "should require success" do
          expect(subject).to receive(:require_success).exactly(2).times
        end

        it "should add outcomes to subject.outcomes" do
          expect { subject.do_the_work }.to change { subject.outcomes.size }.by(2)
        end

        it "should fetch the csv data" do
          allow(subject).to receive(:generate_export_csv).and_return "some,csv,data"
          expect(subject).to receive(:generate_export_csv)
        end

        it "should mail notification that the gradebook was exported" do
          expect(subject).to receive(:notify_gradebook_export)
        end

        it "should return the result of notify_gradebook_export" do
          @export_result = double(:export_result)
          allow(subject).to receive_messages(notify_gradebook_export: @export_result)
          allow(subject).to receive(:fetch_csv_data).and_return "some,csv,data"
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

    end
  end


  # private methods
  
  describe "private methods" do
    describe "fetch_user" do
      subject { performer.instance_eval{fetch_user} }
      it "should fetch the user" do
        expect(subject).to eq(user)
      end

      it "should find the course by id" do
        expect(User).to receive(:find).with(user[:id]) { course }
        performer
      end
    end

    describe "fetch_course" do
      subject { performer.instance_eval{fetch_course} }

      it "should fetch the course" do
       expect(subject).to eq(course)
      end

      it "should find the course by id" do
        expect(Course).to receive(:find).with(course[:id]) { course }
        performer
      end
    end

    describe "fetch_csv_data" do
      subject { performer.instance_eval{fetch_csv_data} }
      let(:course_double) { double(:course) }

      it "should call csv_gradebook on the course" do
        performer.instance_variable_set(:@course, course_double)
        expect(course_double).to receive(:csv_gradebook)
        subject
      end

      it "should find the csv gradebook for the course and return it as a huge string" do
        expect(subject.class).to eq(String)
      end

      it "should return a string in valid CSV format" do
        expect(CSV.parse(subject).class).to eq(Array)
      end
    end

    describe "generate_csv_messages" do
      subject { performer.instance_eval{ generate_csv_messages } }
      it "should have a success message" do
        expect(subject[:success]).to match('Successfully fetched')
      end

      it "should have a failure message" do
        expect(subject[:failure]).to match('Failed to fetch CSV')
      end
    end

    describe "notification_messages" do
      subject { performer.instance_eval{notification_messages} }
      it "should have a success message" do
        expect(subject[:success]).to match('was successfully delivered')
      end

      it "should have a failure message" do
        expect(subject[:failure]).to match('was not delivered')
      end
    end
  end
end
