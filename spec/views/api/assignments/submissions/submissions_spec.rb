describe "api/assignments/submissions/submission" do
  before(:all) do
    @submission = create(:submission)
  end

  it "includes the submission attributes" do
    render
    json = JSON.parse(response.body)
    expect(json["data"]["attributes"].except("created_at", "updated_at", "submitted_at")).to \
      eq @submission.as_json(except: [:created_at, :updated_at, :submitted_at])
    expect(json["data"]["attributes"]["created_at"]).to eq @submission.created_at.as_json
    expect(json["data"]["attributes"]["updated_at"]).to eq @submission.updated_at.as_json
    expect(json["data"]["attributes"]["submitted_at"]).to eq @submission.submitted_at.as_json
  end

  it "includes the id" do
    render
    json = JSON.parse(response.body)
    expect(json["data"]["id"]).to eq @submission.id.to_s
  end

  it "includes the type" do
    render
    json = JSON.parse(response.body)
    expect(json["data"]["type"]).to eq "submission"
  end
end
