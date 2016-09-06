require "light-service"
require "active_record_spec_helper"
require "./app/services/imports_lms_assignments/retrieves_lms_assignment"

describe Services::Actions::RetrievesLMSAssignment do
  let(:access_token) { "TOKEN" }
  let(:imported_assignment) { create :imported_assignment, provider: provider }
  let(:provider) { "canvas" }

  it "expects the provider to retrieve the assignment from" do
    expect { described_class.execute access_token: access_token,
             imported_assignment: imported_assignment }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "expects the access token to use to retrieve the assignment" do
    expect { described_class.execute provider: provider,
             imported_assignment: imported_assignment }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "expects the imported assignment to use to retrieve the lms assignment" do
    expect { described_class.execute access_token: access_token,
             provider: provider }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "retrieves the assignment details from the lms provider" do
    expect(ActiveLMS::Syllabus).to \
      receive(:new).with(provider, access_token).and_call_original
    expect_any_instance_of(ActiveLMS::Syllabus).to \
      receive(:assignment).with(imported_assignment.provider_data[:course_id],
                                imported_assignment.provider_resource_id)
        .and_return ({ name: "Assignment 1" })

    result = described_class.execute access_token: access_token,
      imported_assignment: imported_assignment, provider: provider

    expect(result.lms_assignment[:name]).to eq "Assignment 1"
  end

  it "fails the context if the assignment cannot be found" do
    allow_any_instance_of(ActiveLMS::Syllabus).to \
      receive(:assignment).with(imported_assignment.provider_data[:course_id],
                                imported_assignment.provider_resource_id)
      .and_raise("Resource not found")

    result = described_class.execute access_token: access_token,
      imported_assignment: imported_assignment, provider: provider

    expect(result).to_not be_success
    expect(result.message).to eq "Resource not found"
  end
end
