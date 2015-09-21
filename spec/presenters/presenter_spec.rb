require "rspec/core"
require "./lib/presenter"

describe Presenter::Base do
  subject { Presenter::Base.new }

  describe "#render_options" do
    it "includes a presenter local variable" do
      expect(subject.render_options).to eq({ locals: { presenter: subject } })
    end
  end
end
