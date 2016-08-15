require "analytics/export/progress_message"

describe Analytics::Export::ProgressMessage do
  subject do
    described_class.new record_index: 19, total_records: 40
  end

  describe "readable attributes" do
    it "has a readable record_number" do
      subject.instance_variable_set :@record_number, 99
      expect(subject.record_number).to eq 99
    end

    it "has a readable total_records value" do
      subject.instance_variable_set :@total_records, 100
      expect(subject.total_records).to eq 100
    end
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
  end

  describe "#formatted_message" do
    it "pads the progress message with a newline and some whitespace" do
      allow(subject).to receive(:progress_message) { "...some progress..." }
      expect(subject.formatted_message).to eq "\r       ...some progress..."
    end
  end

  describe "#progress_message" do
    it "returns a message about the progress of the export" do
      allow(subject).to receive_messages \
        record_number: 33,
        total_records: 44,
        percent_complete: 55

      # note that this method is delegating the percentage calculation to the
      # #percent_complete method, and isn't performing the math itself
      expect(subject.progress_message).to eq "record 33 of 44 (55%)"
    end
  end

  describe "#printable?" do
    context "record_number is larger than the total record size" do
      it "returns false" do
        allow(subject).to receive_messages record_number: 500, total_records: 9
        expect(subject.printable?).to eq false
      end
    end

    context "record_number is divisible by five and smaller than the total" do
      it "returns true" do
        allow(subject).to receive_messages record_number: 45, total_records: 200
        expect(subject.printable?).to eq true
      end
    end

    context "record_number is not divisible by five" do
      context "the record_number is for last record in #total_records" do
        it "returns true" do
          allow(subject).to receive_messages record_number: 67, total_records: 67
          expect(subject.printable?).to eq true
        end
      end

      context "the record_number is not for the last record" do
        it "returns false" do
          allow(subject).to receive_messages record_number: 67, total_records: 80
          expect(subject.printable?).to eq false
        end
      end
    end
  end

  describe "#percent_complete" do
    it "divides the record number by the total records and rounds it" do
      allow(subject).to receive_messages record_number: 33, total_records: 50
      expect(subject.percent_complete).to eq 66
    end
  end
end
