require "analytics/export/progress_message"

describe Analytics::Export::ProgressMessage do
  subject do
    described_class.new record_index: 19, total_records: 40, print_every: 70
  end

  describe "#initialize" do
    it "sets the record_number to the record_index plus one" do
      # remember that the record-index is base-zero whereas the record number
      # is base one, which is better for comparison against an array size
      expect(subject.record_number).to eq 20
    end

    it "sets the total_records" do
      expect(subject.total_records).to eq 40
    end

    it "sets the printing frequency" do
      expect(subject.print_every).to eq 70
    end
  end

  describe "#printable?" do
    it "is printable if record_number is larger than the total record size" do
      allow(subject).to receive_messages record_number: 500, total_records: 9
      expect(subject.printable?).to eq false
    end

    it "is printable if the record_number is divisible by print_every" do
      # print_every: value is 70, as defined in the subject above
      allow(subject).to receive_messages record_number: 140, total_records: 200
      expect(subject.printable?).to eq true
    end

    it "is printable if we're on the last record" do
      allow(subject).to receive_messages record_number: 67, total_records: 67
      expect(subject.printable?).to eq true
    end

    it "is not printable if not divisible by print_every, and if not last" do
      allow(subject).to receive_messages record_number: 67, total_records: 80
      expect(subject.printable?).to eq false
    end
  end

  describe "#percent_complete" do
    it "divides the record number by the total records and rounds it" do
      allow(subject).to receive_messages record_number: 33, total_records: 50
      expect(subject.percent_complete).to eq 66
    end
  end

  describe "#to_s" do
    it "prints the message as a string" do
      expect(subject.to_s).to eq "record 20 of 40 (50% complete)"
    end
  end
end
