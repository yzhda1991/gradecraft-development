describe Showtime::Presenter do
  subject { described_class.new }

  describe "#render_options" do
    it "includes a presenter local variable" do
      expect(subject.render_options).to eq({ locals: { presenter: subject } })
    end
  end

  describe ".wrap" do
    class FooPresenter < described_class; end

    let(:collection) { [1, 2, 3] }

    it "wraps a collection of objects with presenter instances" do
      result = FooPresenter.wrap(collection, :item)
      expect(result.map(&:class).uniq).to eq [FooPresenter]
      expect(result.first.properties[:item]).to eq 1
    end

    it "wraps with arguments" do
      result = FooPresenter.wrap(collection, :item, { foo: :bar })
      expect(result.first.properties[:foo]).to eq :bar
    end
  end
end
