require 'spec_helper'

RSpec.describe EventsHelper::Lull, type: :helper do

  # next_lull_start - Time.now
  describe "#time_until_next_lull" do
    it "should return seconds until the next lull" do
      allow(Time).to receive_messages(now: Time.parse("Oct 24 1985"))
      allow(helper).to receive_messages(next_lull_start: Time.parse("Oct 26 1985"))
      expect(helper.time_until_next_lull).to eq(2.days.to_f)
    end
  end

  # Time.now < todays_lull_start
  describe "#is_before_todays_lull" do
    it "should be true if todays lull happens after right now" do
      Time.now < todays_lull_start
    end


    it "should be false if todays lull has already started" do
    end
  end

  # Time.now > todays_lull_end
  describe "#is_after_todays_lull" do
    it "should be true if today's lull is already over" do
    end

    it "should be false if today's lull hasn't ended yet" do
    end
  end

  # Time.now > todays_lull_start and
  # Time.now < todays_lull_end
  describe "#is_during_todays_lull" do
    it "should be true if it's after the lull has started but before it's ended" do
    end

    it "should be false if before the lull has started" do
    end

    it "should be false if after the lull has ended" do
    end
  end

  # if is_after_todays_lull?
  #   tomorrows_lull_start
  # else
  #   todays_lull_start
  # end
  describe "#next_lull_start" do
    it "should return the start time of tomorrow's lull if after today's lull" do
    end

    it "should return today's lull start time if it hasn't ended yet" do
    end
  end

  describe "#tomorrows_lull_start" do
    DateTime.tomorrow.to_time.change(LULL_START_PARAMS)
  end

  describe "#todays_lull_end" do
    Time.now.change(LULL_END_PARAMS)
  end

  describe "#todays_lull_start" do
    Time.now.change(LULL_START_PARAMS)
  end

end
