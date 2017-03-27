describe "api/users/search" do
  let(:user) { build_stubbed :user }
  let(:another_user) { build_stubbed :user }

  before(:each) do
    @users = [user, another_user]
  end

  it "responds with users" do
    render
    json = JSON.parse(response.body)
    expect(json["data"].pluck("type")).to match_array ["user", "user"]
  end

  it "adds the attributes to the user" do
    render
    json = JSON.parse(response.body)
    expect(json["data"][0]["attributes"]["id"]).to eq(user.id.to_s)
    expect(json["data"][0]["attributes"]["first_name"]).to eq(user.first_name)
    expect(json["data"][0]["attributes"]["last_name"]).to eq(user.last_name)
    expect(json["data"][1]["attributes"]["id"]).to eq(another_user.id.to_s)
    expect(json["data"][1]["attributes"]["first_name"]).to eq(another_user.first_name)
    expect(json["data"][1]["attributes"]["last_name"]).to eq(another_user.last_name)
  end
end
