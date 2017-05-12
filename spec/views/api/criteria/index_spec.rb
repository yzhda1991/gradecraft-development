describe "api/criteria/index" do
  let(:course) { build_stubbed(:course) }
  let(:assignment) { create(:assignment, course: course) }
  let(:rubric) { create(:rubric, assignment: assignment) }
  let(:criterion) { create(:criterion, rubric: rubric) }

  before(:each) do
    @criteria = [criterion]
    @levels = criterion.levels
    allow(view).to receive(:current_course).and_return(course)
  end

  it "responds with an array of criteria" do
    render
    json = JSON.parse(response.body)
    expect(json["data"].length).to eq(1)
  end

  it "adds the attributes to the criteria" do
    render
    json = JSON.parse(response.body)
    expect(json["data"][0]["attributes"]["id"]).to eq(@criteria[0].id)
    expect(json["data"][0]["attributes"]["name"]).to eq(@criteria[0].name)
    expect(json["data"][0]["attributes"]["description"]).to eq(@criteria[0].description)
    expect(json["data"][0]["attributes"]["max_points"]).to eq(@criteria[0].max_points)
    expect(json["data"][0]["attributes"]["order"]).to eq(@criteria[0].order)
  end

  it "adds levels in included" do
    render
    json = JSON.parse(response.body)
    expect(json["included"].count).to eq(@criteria[0].levels.count)
    expect(json["included"][0]["attributes"]["id"]).to eq(@criteria[0].levels.first.id)
  end

  describe "level badges" do
    before do
      allow_any_instance_of(Level).to receive(:level_badges)
      .and_return [double(:level_badge, id: 123, level_id: 456, badge_id: 789, "[]" => [789])]
    end

    it "adds level badges to the level" do
      render
      json = JSON.parse(response.body)
      expect(json["included"][0]["attributes"]["level_badges"][0]).to \
        eq("id" => 123, "level_id" => 456, "badge_id" => 789)
    end

    it "adds level available badges to the level" do
      allow(course).to receive(:badges).and_return [double(:badge, id: 122, name: "availbadge")]
      render
      json = JSON.parse(response.body)
      expect(json["included"][0]["attributes"]["available_badges"][0]).to \
        eq("id" => 122, "name" => "availbadge")
    end

    it "remove awarded badges from the available badges" do
      render
      json = JSON.parse(response.body)
      allow(course).to receive(:badges).and_return [double(:badge, id: 789, name: "unavailbadge")]
      expect(json["included"][0]["attributes"]["available_badges"][0]).to eq nil
    end
  end
end
