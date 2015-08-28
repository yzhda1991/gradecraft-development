require 'spec_helper'

describe Event do
   before do
    @event = build(:event)
  end

  subject { @event }

  it { is_expected.to respond_to("course_id")}
  it { is_expected.to respond_to("created_at")}
  it { is_expected.to respond_to("description")}
  it { is_expected.to respond_to("due_at")}
  it { is_expected.to respond_to("media")}
  it { is_expected.to respond_to("media_caption")}
  it { is_expected.to respond_to("media_credit")}
  it { is_expected.to respond_to("name")}
  it { is_expected.to respond_to("open_at")}
  it { is_expected.to respond_to("thumbnail")}
  it { is_expected.to respond_to("updated_at")}

  it { is_expected.to be_valid }

  #validations
  it "is valid with a name and due at date" do
    expect(build(:assignment)).to be_valid
  end

  it "is invalid without a name" do
    event = build(:event, name: nil)
    expect(event).to_not be_valid
    expect(event.errors[:name].count).to eq 1
  end
end
