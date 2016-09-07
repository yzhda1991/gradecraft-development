require "light-service"
require "active_record_spec_helper"
require "./app/services/imports_lms_assignments/updates_imported_timestamp"

describe Services::Actions::UpdatesImportedTimestamp do
  let(:imported_assignment) { create :imported_assignment, :canvas }

  it "expects the imported assignment to use to update" do
    expect { described_class.execute }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "updates the imported timestamp" do
    result = described_class.execute imported_assignment: imported_assignment

    expect(result.imported_assignment.last_imported_at).to \
      be_within(1.second).of(DateTime.now)
  end
end
