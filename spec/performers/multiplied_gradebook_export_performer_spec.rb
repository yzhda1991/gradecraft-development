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
      expect(course_double).to receive(:csv_multipled_gradebook)
      subject
    end
  end
end
