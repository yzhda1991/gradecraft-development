require "rspec/core"
require "./lib/showtime/presenter"

describe Showtime::Presenter do
  subject { described_class.new }

  describe "#render_options" do
    it "includes a presenter local variable" do
      expect(subject.render_options).to eq({ locals: { presenter: subject } })
    end
  end
end
