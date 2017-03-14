describe CollectionMerger do
  describe "#merge" do
    let(:seed_date) { DateTime.now }
    let(:first) { double(:first, created_at: seed_date - 4) }
    let(:second) { double(:second, created_at: seed_date - 3) }
    let(:third) { double(:third, created_at: seed_date - 2) }
    let(:fourth) { double(:fourth, created_at: seed_date - 1) }

    let(:collection1) { [first, third] }
    let(:collection2) { [second, fourth] }

    subject { described_class.new(collection1, collection2) }

    it "returns the left side if the right side is nil" do
      subject = described_class.new(collection1, nil)

      expect(subject.merge).to eq collection1
    end

    it "merges collections on a created at field by default" do
      expect(subject.merge).to eq [first, second, third, fourth]
    end

    it "can merge on a different field as an option" do
      allow(first).to receive(:blah).and_return seed_date - 1
      allow(second).to receive(:blah).and_return seed_date - 2
      allow(third).to receive(:blah).and_return seed_date - 3
      allow(fourth).to receive(:blah).and_return seed_date - 4
      expect(subject.merge(field: :blah)).to eq [fourth, third, second, first]
    end

    it "can merge on a different field via a proc" do
      allow(first).to receive(:method).and_return seed_date - 1
      allow(second).to receive(:method).and_return seed_date - 2
      allow(third).to receive(:method).and_return seed_date - 3
      allow(fourth).to receive(:method).and_return seed_date - 4
      expect(subject.merge(field: ->(obj) { obj.method })).to \
        eq [fourth, third, second, first]
    end

    it "can merge in a descending order" do
      expect(subject.merge(order: :desc)).to eq [fourth, third, second, first]
    end
  end
end
