# spec/models/unlock_condition_spec.rb

require 'spec_helper'

describe UnlockCondition do

  before(:each) do
    @unlock_condition = UnlockCondition.new(:unlockable_id => 1, :unlockable_type => "Assignment", :condition_id => 2, :condition_type => "Badge", :condition_state => "Earned")
  end

  subject { @unlock_condition }

  it { should respond_to("unlockable_id")}
  it { should respond_to("unlockable_type")}
  it { should respond_to("condition_id")}
  it { should respond_to("condition_type")}
  it { should respond_to("condition_state")}
  it { should respond_to("condition_date")}

  it { should be_valid }

  describe "when no information is present" do
    before { 
      @unlock_condition.unlockable_id = nil
      @unlock_condition.unlockable_type = nil
      @unlock_condition.condition_id = nil
      @unlock_condition.condition_type = nil
      @unlock_condition.condition_state = nil 
    }
    it { should_not be_valid }
  end

  it "can be saved with a state and a value" do
    @unlock_condition.unlockable_id = 1
    @unlock_condition.unlockable_type = "Assignment"
    @unlock_condition.condition_id = 2
    @unlock_condition.condition_type = "Badge"
    @unlock_condition.condition_state = "Earned"
    @unlock_condition.condition_value = 2
    expect @unlock_condition.should have(0).errors
  end

  it "can be saved with a state, a value, and a date" do
    @unlock_condition.unlockable_id = 1
    @unlock_condition.unlockable_type = "Assignment"
    @unlock_condition.condition_id = 2
    @unlock_condition.condition_type = "Badge"
    @unlock_condition.condition_state = "Earned"
    @unlock_condition.condition_value = 2
    @unlock_condition_date = Date.today
    expect @unlock_condition.should have(0).errors
  end

end