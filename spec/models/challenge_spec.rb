#challenge_spec.rb
require 'spec_helper'

describe Challenge do

  before do
    @challenge = build(:challenge)
  end

  subject { @challenge }

  it { is_expected.to respond_to("name")}
  it { is_expected.to respond_to("description")}
  it { is_expected.to respond_to("point_total")}
  it { is_expected.to respond_to( "due_at")}
  it { is_expected.to respond_to("course_id")}
  it { is_expected.to respond_to("points_predictor_display")}
  it { is_expected.to respond_to("visible")}
  it { is_expected.to respond_to("accepts_submissions")}
  it { is_expected.to respond_to("release_necessary")}
  it { is_expected.to respond_to("created_at")}
  it { is_expected.to respond_to("updated_at")}
  it { is_expected.to respond_to("open_at")}
  it { is_expected.to respond_to("mass_grade")}
  it { is_expected.to respond_to("mass_grade_type")}
  it { is_expected.to respond_to("levels")}
  it { is_expected.to respond_to("media")}
  it { is_expected.to respond_to("thumbnail")}
  it { is_expected.to respond_to("media_credit")}
  it { is_expected.to respond_to("media_caption")}

  it { is_expected.to be_valid }

  it "is invalid without a name" do
    @challenge.name = nil
    expect(@challenge).to_not be_valid
    expect(@challenge.errors[:name].count).to eq 1
  end

  it "is invalid without a course" do
    @challenge.course = nil
    expect(@challenge).to_not be_valid
    expect(@challenge.errors[:course].count).to eq 1
  end
end
