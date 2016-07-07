require "active_record_spec_helper"
require_relative "../support/uni_mock/rails"

RSpec.describe SubmissionsExport do
  subject { described_class.new }

  let(:course) { create(:course) }
  let(:professor) { create(:user) }
  let(:team) { create(:team) }
  let(:assignment) { create(:assignment) }

  describe "validations" do
    describe "course_id" do
      let(:result) { create(:submissions_export, course: nil) }
      it "requires a course_id" do
        expect { result }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    describe "assignment_id" do
      let(:result) { create(:submissions_export, course: nil) }

      it "requires an assignment_id" do
        expect { result }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end

end
