describe QuoteHelper do
  class Container
    include QuoteHelper
  end

  subject { Container.new }

  describe "#remove_smart_quotes" do
    it "removes single smart quotes" do
      with_smart_quotes = "\u2018this is a thing\u2019"
      expect(subject.remove_smart_quotes(with_smart_quotes)).to eq "this is a thing"
    end

    it "removes double smart quotes" do
      with_smart_quotes = "\u201Cthis is a thing\u201D"
      expect(subject.remove_smart_quotes(with_smart_quotes)).to eq "this is a thing"
    end

    it "handles nil string" do
      expect(subject.remove_smart_quotes(nil)).to eq ""
    end
  end
end
