describe ResqueJob::Outcome,  type: :vendor_library do
  subject { described_class.new result }
  # note that this is the result of the outcome block, not the conventional
  # #result method that we've established in other specs
  let(:result) { "some outcome" }

  describe "initialize" do
    it "should set the result" do
      expect(subject.result).to eq result
    end

    it "should have a nil messages value by default" do
      expect(subject.message).to be_nil
    end
  end

  describe "attributes" do
    it "should have an accessible message" do
      subject.message = "some message"
      expect(subject.message).to eq "some message"
    end

    it "should have accessible options" do
      subject.options = "these are options"
      expect(subject.options).to eq "these are options"
    end
  end

  describe "success?" do
    context "@result is neither false nor nil" do
      it "should be true" do
        expect(subject.success?).to eq true
      end
    end

    context "@result is false" do
      it "should be false" do
        subject.result = false
        expect(subject.success?).to eq false
      end
    end

    context "@result is nil" do
      it "should be false" do
        subject.result = nil
        expect(subject.success?).to eq false
      end
    end
  end

  describe "failure?" do
    context "@result is neither false nor nil" do
      it "should be false" do
        expect(subject.failure?).to eq false
      end
    end

    context "@result is false" do
      it "should be true" do
        subject.result = false
        expect(subject.failure?).to eq true
      end
    end

    context "@result is nil" do
      it "should be true" do
        subject.result = nil
        expect(subject.failure?).to eq true
      end
    end
  end
end
