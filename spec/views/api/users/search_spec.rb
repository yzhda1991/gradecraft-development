describe "api/users/search" do
  let(:course) { build :course, name: "Rocket Science 601" }
  let!(:student_membership) { create(:course_membership, :student, course: course, user: student, score: 124816) }
  let!(:professor_membership) { create(:course_membership, :professor, course: course, user: professor)  }
  let(:student) { build_stubbed :user, first_name: "Jacob", last_name: "Leinenkugel" }
  let(:professor) { build_stubbed :user, first_name: "Jacob", last_name: "Leinenkugel" }

  before(:each) do
    allow(view).to receive(:term_for).with("student", "Student").and_return("Learner")
    allow(view).to receive(:term_for).with("professor", "Professor").and_return("Professor")
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
    expect(json["data"][0]["attributes"]["course_memberships"]).to eq [{
      "course_id"=>course.id,
      "role"=>"Learner",
      "course_name"=>"Rocket Science 601",
      "score"=>124816
    }]
    expect(json["data"][1]["attributes"]["id"]).to eq professor.id.to_s
    expect(json["data"][1]["attributes"]["first_name"]).to eq "Jacob"
    expect(json["data"][1]["attributes"]["last_name"]).to eq "Leinenkugel"
    expect(json["data"][1]["attributes"]["course_memberships"]).to eq [{
      "course_id"=>course.id,
      "role"=>"Professor",
      "course_name"=>"Rocket Science 601"
    }]
  end
end
