require 'spec_helper'

describe Event do
   before do
    @event = build(:event)
  end

  subject { @event }

  it { should respond_to("course_id")}
  it { should respond_to("created_at")}
  it { should respond_to("description")}
  it { should respond_to("due_at")}
  it { should respond_to("media")}
  it { should respond_to("media_caption")}
  it { should respond_to("media_credit")}
  it { should respond_to("name")}
  it { should respond_to("open_at")}
  it { should respond_to("thumbnail")}
  it { should respond_to("updated_at")}

  it { should be_valid }

  #validations
  it "is valid with a name and due at date" do
    expect(build(:assignment)).to be_valid
  end

  it "is invalid without a name" do 
  	expect(build(:event, name: nil)).to have(1).errors_on(:name)
  end
end
