describe "api/users/search" do
  let(:course) { build :course, name: "Rocket Science 601" }
  let!(:student_membership) { create(:course_membership, :student, course: course, user: student, score: 124816) }
  let!(:professor_membership) { create(:course_membership, :professor, course: course, user: professor)  }
  let(:student) { build_stubbed :user, first_name: "Jacob", last_name: "Leinenkugel" }
  let(:professor) { build_stubbed :user, first_name: "Jacob", last_name: "Leinenkugel" }

  before(:each) do
    @users = [student, professor]
    render
  end

  it "responds with users" do
    json = JSON.parse(response.body)
    expect(json["data"].length).to eq 2
    expect(json["data"].pluck("type")).to match_array ["user", "user"]
  end

  it "adds the attributes for the users" do
    json = JSON.parse(response.body)
    expect(json["data"][0]["attributes"]["id"]).to eq student.id.to_s
    expect(json["data"][0]["attributes"]["first_name"]).to eq "Jacob"
    expect(json["data"][0]["attributes"]["last_name"]).to eq "Leinenkugel"
    expect(json["data"][1]["attributes"]["id"]).to eq professor.id.to_s
    expect(json["data"][1]["attributes"]["first_name"]).to eq "Jacob"
    expect(json["data"][1]["attributes"]["last_name"]).to eq "Leinenkugel"
  end

  it "adds the relationships for the users" do
    json = JSON.parse(response.body)
    expect(json["data"][0]["relationships"]["data"][0]["id"]).to eq student_membership.id.to_s
    expect(json["data"][0]["relationships"]["data"][0]["type"]).to eq "course_membership"
    expect(json["data"][1]["relationships"]["data"][0]["id"]).to eq professor_membership.id.to_s
    expect(json["data"][1]["relationships"]["data"][0]["type"]).to eq "course_membership"
  end

  it "adds the included data" do
    json = JSON.parse(response.body)
    expect(json["data"][0]["included"][0]["id"]).to eq student_membership.id.to_s
    expect(json["data"][0]["included"][0]["type"]).to eq "course_membership"
    expect(json["data"][0]["included"][0]["course_name"]).to eq "Rocket Science 601"
    expect(json["data"][0]["included"][0]["role"]).to eq "student"
    expect(json["data"][0]["included"][0]["score"]).to eq "124816"
    expect(json["data"][1]["included"][0]["id"]).to eq professor_membership.id.to_s
    expect(json["data"][1]["included"][0]["type"]).to eq "course_membership"
    expect(json["data"][1]["included"][0]["course_name"]).to eq "Rocket Science 601"
    expect(json["data"][1]["included"][0]["role"]).to eq "professor"
    expect(json["data"][1]["included"][0]["score"]).to be_nil
  end
end
