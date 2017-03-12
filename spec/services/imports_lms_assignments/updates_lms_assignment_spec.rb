describe Services::Actions::UpdatesLMSAssignment do
  let(:access_token) { "TOKEN" }
  let(:assignment) { create :assignment }
  let(:imported_assignment) { create :imported_assignment, assignment: assignment,
                              provider: provider }
  let(:provider) { "canvas" }

  it "expects the provider to update the assignment on" do
    expect { described_class.execute access_token: access_token,
             imported_assignment: imported_assignment }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "expects the access token to use to update the assignment" do
    expect { described_class.execute provider: provider,
             imported_assignment: imported_assignment }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "expects the imported assignment to use to update the lms assignment" do
    expect { described_class.execute access_token: access_token,
             provider: provider }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "updates the lms assignment" do
    params = {
      name: assignment.name,
      description: assignment.description,
      due_at: assignment.due_at,
      points_possible: assignment.full_points
    }
    expect(ActiveLMS::Syllabus).to \
      receive(:new).with(provider, access_token).and_call_original
    expect_any_instance_of(ActiveLMS::Syllabus).to \
      receive(:update_assignment).with(imported_assignment.provider_data["course_id"],
                                imported_assignment.provider_resource_id,
                                { assignment: params })
        .and_return (params)

    result = described_class.execute access_token: access_token,
      imported_assignment: imported_assignment, provider: provider

    expect(result.lms_assignment[:name]).to eq assignment.name
  end

  it "fails the context if the assignment cannot be found" do
    allow_any_instance_of(ActiveLMS::Syllabus).to \
      receive(:update_assignment).with(imported_assignment.provider_data["course_id"],
                                       imported_assignment.provider_resource_id,
                                       hash_including(:assignment))
      .and_raise("Resource not found")

    result = described_class.execute access_token: access_token,
      imported_assignment: imported_assignment, provider: provider

    expect(result).to_not be_success
    expect(result.message).to eq "Resource not found"
  end
end
