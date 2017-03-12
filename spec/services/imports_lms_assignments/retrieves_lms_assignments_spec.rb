describe Services::Actions::RetrievesLMSAssignments do
  let(:access_token) { "TOKEN" }
  let(:assignment_ids) { ["ASSIGNMENT_1", "ASSIGNMENT_2"] }
  let(:course_id) { "COURSE_ID" }
  let(:provider) { "canvas" }

  it "expects the provider to retrieve the assignments from" do
    expect { described_class.execute access_token: access_token, course_id: course_id,
             assignment_ids: assignment_ids }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "expects the access token to use to retrieve the assignments" do
    expect { described_class.execute provider: provider, course_id: course_id,
             assignment_ids: assignment_ids }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "expects the provider's course id to retrieve the assignments from" do
    expect { described_class.execute provider: provider, access_token: access_token,
             assignment_ids: assignment_ids }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "expects the provider's assignment ids to retrieve the assignments from" do
    expect { described_class.execute provider: provider, access_token: access_token,
             course_id: course_id }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "retrieves the assignment details from the lms provider" do
    expect(ActiveLMS::Syllabus).to \
      receive(:new).with(provider, access_token).and_call_original
    expect_any_instance_of(ActiveLMS::Syllabus).to \
      receive(:assignments).with(course_id, assignment_ids)
        .and_return [{ name: "Assignment 1" }, { name: "Assignment 2" }]

    result = described_class.execute provider: provider, access_token: access_token,
      assignment_ids: assignment_ids, course_id: course_id
  end
end
