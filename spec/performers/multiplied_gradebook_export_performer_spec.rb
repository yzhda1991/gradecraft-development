require 'rails_spec_helper'

RSpec.describe MultipliedGradebookExportPerformer, type: :background_job do
  let(:course) { create(:course) }
  let(:user) { create(:user) }
  let(:attrs) {{ user_id: user.id, course_id: course.id }}
  let(:performer) { MultipliedGradebookExportPerformer.new(attrs) }

  describe "fetch_csv_data" do
    let(:course_double) { double(:course) }
    subject { performer.instance_eval{fetch_csv_data} }

    it "should call csv_multipled_gradebook on the course" do
      performer.instance_variable_set(:@course, course_double)
      expect(course_double).to receive(:csv_multiplied_gradebook)
      subject
    end
  end

  describe "notify_gradebook_export" do
    let(:csv_data) { performer.instance_variable_get(:@csv_data) }
    subject { performer.instance_eval { notify_gradebook_export } }

    it "should create a new gradebook export notifier with proper parameters" do
      expect(NotificationMailer).to receive(:gradebook_export)
        .with(course, user, "multiplied gradebook export", csv_data)
        .and_call_original
      subject
    end
  end
end
