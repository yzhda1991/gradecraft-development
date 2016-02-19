require "rails_spec_helper"

RSpec.describe EventsHelper::Lull, type: :helper do

  # next_lull_start - Time.now
  describe "#time_until_next_lull" do
    it "should return seconds until the next lull" do
      allow(Time).to receive_messages(now: six_am)
      allow(helper).to receive_messages(next_lull_start: noon)
      expect(helper.time_until_next_lull).to eq(6.hours.to_f)
    end
  end

  # Time.now < todays_lull_start
  describe "#is_before_todays_lull" do
    before do
      allow(Time).to receive_messages(now: noon)
    end

    it "should be true if todays lull happens after right now" do
      allow(helper).to receive_messages(todays_lull_start: five_pm)
      expect(helper.is_before_todays_lull?).to be_truthy
    end


    it "should be false if todays lull has already started" do
      allow(helper).to receive_messages(todays_lull_start: six_am)
      expect(helper.is_before_todays_lull?).to be_falsey
    end
  end

  # Time.now > todays_lull_end
  describe "#is_after_todays_lull" do
    before do
      allow(Time).to receive_messages(now: noon)
    end

    it "should be true if today's lull is already over" do
      allow(helper).to receive_messages(todays_lull_end: six_am)
      expect(helper.is_after_todays_lull?).to be_truthy
    end

    it "should be false if today's lull hasn't ended yet" do
      allow(helper).to receive_messages(todays_lull_end: five_pm)
      expect(helper.is_after_todays_lull?).to be_falsey
    end
  end

  # Time.now > todays_lull_start and
  # Time.now < todays_lull_end
  describe "#is_during_todays_lull" do
    before do
      allow(Time).to receive_messages(now: noon)
    end

    it "should be true if it's after the lull has started but before it's ended" do
      allow(helper).to receive_messages(todays_lull_start: six_am)
      allow(helper).to receive_messages(todays_lull_end: five_pm)
      expect(helper.is_during_todays_lull?).to be_truthy
    end

    it "should be false if before the lull has started" do
      allow(helper).to receive_messages(todays_lull_start: five_pm)
      expect(helper.is_during_todays_lull?).to be_falsey
    end

    it "should be false if after the lull has ended" do
      allow(helper).to receive_messages(todays_lull_end: six_am)
      expect(helper.is_during_todays_lull?).to be_falsey
    end
  end

  # is_after_todays_lull? ? tomorrows_lull_start : todays_lull_start
  describe "#next_lull_start" do
    it "should return the start time of tomorrow's lull if after today's lull" do
      tomorrows_lull_start = double("Tomorrow's Lull Start")
      allow(helper).to receive_messages(tomorrows_lull_start: tomorrows_lull_start)
      allow(helper).to receive_messages(is_after_todays_lull?: true)
      expect(helper.next_lull_start).to eq(tomorrows_lull_start)
    end

    it "should return today's lull start time if it hasn't ended yet" do
      todays_lull_start = double("Today's Lull Start")
      allow(helper).to receive_messages(todays_lull_start: todays_lull_start)
      allow(helper).to receive_messages(is_after_todays_lull?: false)
      expect(helper.next_lull_start).to eq(todays_lull_start)
    end
  end

  describe "fundamental lull helpers" do
    before do
      @today = october(15)
      @tomorrow = october(16)
      allow(helper).to receive_messages(lull_start_params: {hour: 15, min: 20})
      allow(helper).to receive_messages(lull_end_params: {hour: 18, min: 40})
    end

    # DateTime.tomorrow.to_time.change(LULL_START_PARAMS)
    describe "#tomorrows_lull_start" do
      it "should match Tomorrow's lull start time" do
        allow(Date).to receive_message_chain(:tomorrow, :to_time) { @tomorrow }
        expect(helper.tomorrows_lull_start).to eq(@tomorrow.change(hour: 15, min: 20))
      end
    end

    # Time.now.change(LULL_END_PARAMS)
    describe "#todays_lull_end" do
      it "should match today's lull end" do
        allow(Time).to receive_messages(now: @today)
        expect(helper.todays_lull_end).to eq(@today.change(hour: 18, min: 40))
      end
    end

    # Time.now.change(LULL_START_PARAMS)
    describe "#todays_lull_start" do
      it "should match today's lull start" do
        allow(Time).to receive_messages(now: @today)
        expect(helper.todays_lull_start).to eq(@today.change(hour: 15, min: 20))
      end
    end
  end

  private
  def five_pm
    @five_pm ||= Time.now.change(hour: 17, min: 0)
  end

  def noon
    @noon ||= Time.now.change(hour: 12, min: 0)
  end

  def six_am
    @six_am ||= Time.now.change(hour: 6, min: 0)
  end

  def october(day_of_month)
    Time.parse("Oct #{day_of_month} #{Time.now.year}")
  end
end
