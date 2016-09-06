require "light-service"
require "active_record_spec_helper"
require "./app/services/imports_lms_assignments/retrieves_imported_assignment"

describe Services::Actions::RetrievesImportedAssignment do
  let(:assignment) { create :assignment }
  let(:provider) { "canvas" }

  it "expects a provider to retrieve the imported assignment for" do
    expect { described_class.execute assignment: assignment }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "expects an assignment to retrieve the imported assignment for" do
    expect { described_class.execute provider: provider }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "retrieves the imported assignment" do
    imported_assignment = create :imported_assignment, provider: provider,
      assignment: assignment

    result = described_class.execute assignment: assignment, provider: provider

    expect(result.imported_assignment).to eq imported_assignment
  end

  it "fails the context if the assignment was not previously imported" do
    result = described_class.execute assignment: assignment, provider: provider

    expect(result).to_not be_success
  end
end
