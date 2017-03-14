# pull in various time helper methods
include Toolkits::Lib::LullToolkit

describe Lull, type: :vendor_library do

  # next_lull_start - Time.zone.now
  describe "#time_until_next_lull" do
    it "should return seconds until the next lull" do
      allow(Time.zone).to receive_messages(now: six_am)
      allow(Lull).to receive_messages(next_lull_start: noon)
      expect(Lull.time_until_next_lull).to eq(6.hours.to_f)
    end
  end

  # Time.zone.now < todays_lull_start
  describe "#before_todays_lull" do
    before do
      allow(Time).to receive_messages(now: noon)
    end

    it "should be true if todays lull happens after right now" do
      allow(Lull).to receive_messages(todays_lull_start: five_pm)
      expect(Lull.before_todays_lull?).to be_truthy
    end

    it "should be false if todays lull has already started" do
      allow(Lull).to receive_messages(todays_lull_start: six_am)
      expect(Lull.before_todays_lull?).to be_falsey
    end
  end

  # Time.zone.now > todays_lull_end
  describe "#after_todays_lull" do
    before do
      allow(Time).to receive_messages(now: noon)
    end

    it "should be true if today's lull is already over" do
      allow(Lull).to receive_messages(todays_lull_end: six_am)
      expect(Lull.after_todays_lull?).to be_truthy
    end

    it "should be false if today's lull hasn't ended yet" do
      allow(Lull).to receive_messages(todays_lull_end: five_pm)
      expect(Lull.after_todays_lull?).to be_falsey
    end
  end

  # Time.zone.now > todays_lull_start and
  # Time.zone.now < todays_lull_end
  describe "#during_todays_lull" do
    before do
      allow(Time.zone).to receive_messages(now: noon)
    end

    it "should be true if it's after the lull has started but before it's ended" do
      allow(Lull).to receive_messages(todays_lull_start: six_am)
      allow(Lull).to receive_messages(todays_lull_end: five_pm)
      expect(Lull.during_todays_lull?).to be_truthy
    end

    it "should be false if before the lull has started" do
      allow(Lull).to receive_messages(todays_lull_start: five_pm)
      expect(Lull.during_todays_lull?).to be_falsey
    end

    it "should be false if after the lull has ended" do
      allow(Lull).to receive_messages(todays_lull_end: six_am)
      expect(Lull.during_todays_lull?).to be_falsey
    end
  end

  # after_todays_lull? ? tomorrows_lull_start : todays_lull_start
  describe "#next_lull_start" do
    it "should return the start time of tomorrow's lull if after today's lull" do
      tomorrows_lull_start = double("Tomorrow's Lull Start")
      allow(Lull).to receive_messages(tomorrows_lull_start: tomorrows_lull_start)
      allow(Lull).to receive_messages(after_todays_lull?: true)
      expect(Lull.next_lull_start).to eq(tomorrows_lull_start)
    end

    it "should return today's lull start time if it hasn't ended yet" do
      todays_lull_start = double("Today's Lull Start")
      allow(Lull).to receive_messages(todays_lull_start: todays_lull_start)
      allow(Lull).to receive_messages(after_todays_lull?: false)
      expect(Lull.next_lull_start).to eq(todays_lull_start)
    end
  end

  describe "fundamental lull Lulls" do
    let(:today) { october(15) }
    let(:tomorrow) { october(16) }

    before do
      allow(Lull).to receive_messages(lull_start_params: {hour: 15, min: 20})
      allow(Lull).to receive_messages(lull_end_params: {hour: 18, min: 40})
    end

    # DateTime.tomorrow.to_time.change(LULL_START_PARAMS)
    describe "#tomorrows_lull_start" do
      it "should match Tomorrow's lull start time" do
        allow(Date).to receive_message_chain(:tomorrow, :to_time) { tomorrow }
        expect(Lull.tomorrows_lull_start).to eq(tomorrow.change(hour: 15, min: 20))
      end
    end

    # Time.zone.now.change(LULL_END_PARAMS)
    describe "#todays_lull_end" do
      it "should match today's lull end" do
        allow(Time.zone).to receive_messages(now: today)
        expect(Lull.todays_lull_end).to eq(today.change(hour: 18, min: 40))
      end
    end

    # Time.zone.now.change(LULL_START_PARAMS)
    describe "#todays_lull_start" do
      it "should match today's lull start" do
        allow(Time.zone).to receive_messages(now: today)
        expect(Lull.todays_lull_start).to eq(today.change(hour: 15, min: 20))
      end
    end
  end
end
