describe Services::Actions::RetrievesLMSGrades do
  let(:access_token) { "TOKEN" }
  let(:assignment_ids) { ["ASSIGNMENT_1", "ASSIGNMENT_2"] }
  let(:course_id) { "COURSE_ID" }
  let(:grade_ids) { ["GRADE_1", "GRADE_2"] }
  let(:provider) { "canvas" }

  it "expects the provider to retrieve the grades from" do
    expect { described_class.execute access_token: access_token, course_id: course_id,
             assignment_ids: assignment_ids, grade_ids: grade_ids }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "expects the access token to use to retrieve the grades" do
    expect { described_class.execute provider: provider, course_id: course_id,
             assignment_ids: assignment_ids, grade_ids: grade_ids }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "expects the provider's course id to retrieve the grades from" do
    expect { described_class.execute provider: provider, access_token: access_token,
             assignment_ids: assignment_ids, grade_ids: grade_ids }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "expects the provider's assignment ids to retrieve the grades from" do
    expect { described_class.execute provider: provider, access_token: access_token,
             course_id: course_id, grade_ids: grade_ids }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "expects the provider's grade ids to retrieve the grades from" do
    expect { described_class.execute provider: provider, access_token: access_token,
             course_id: course_id, assignment_ids: assignment_ids }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "retrieves the grade details from the lms provider" do
    expect(ActiveLMS::Syllabus).to \
      receive(:new).with(provider, access_token).and_call_original
    expect_any_instance_of(ActiveLMS::Syllabus).to \
      receive(:grades).with(course_id, assignment_ids, grade_ids)
        .and_return({ grades: [{ grade: "A+" }, { grade: "D-" }] })

    described_class.execute provider: provider, access_token: access_token,
      course_id: course_id, assignment_ids: assignment_ids, grade_ids: grade_ids
  end

  it "promises the user ids from the grades" do
    allow_any_instance_of(ActiveLMS::Syllabus).to \
      receive(:grades).and_return({ grades: [{ "user_id" => "123" }] })

    result = described_class.execute provider: provider, access_token: access_token,
      course_id: course_id, assignment_ids: assignment_ids, grade_ids: grade_ids

    expect(result).to have_key :user_ids
  end

  it "fails the context if an error occurs" do
    allow_any_instance_of(ActiveLMS::Syllabus).to receive(:grades) { |&b| b.call }

    result = described_class.execute provider: provider, access_token: access_token,
      course_id: course_id, assignment_ids: assignment_ids, grade_ids: grade_ids

    expect(result).to_not be_success
    expect(result.message).to eq "An error occurred while attempting to retrieve #{provider} grades"
  end
end
