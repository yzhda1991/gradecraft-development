RSpec.describe PredictorEventLogger, type: :event_logger do
  subject { described_class.new }
  let(:application_attrs) { { waffles: "son" } }

  before(:each) do
    allow(subject).to receive(:application_attrs) { application_attrs }
  end

  it "inherits from the ApplicationEventLogger" do
    expect(described_class.superclass).to eq ApplicationEventLogger
  end

  it "has an #event_type" do
    expect(subject.event_type).to eq "predictor"
  end

  it "includes EventLogger::Enqueue" do
    expect(subject).to respond_to(:enqueue_in_with_fallback)
  end

  it "uses the :predictor_event_logger queue" do
    expect(described_class.queue).to eq :predictor_event_logger
  end

  describe "#event_attrs" do
    let(:result) { subject.event_attrs }

    context "a params hash exists" do
      let(:params) { { great: "seriously" } }
      let(:param_attrs) { { these: "are-great" } }

      it "merges the param_attrs with the with the application_attrs" do
        allow(subject).to receive_messages({ params: params, \
          param_attrs: param_attrs })

        expect(result).to eq subject.application_attrs.merge(param_attrs)
      end
    end

    context "params does not exist" do
      let(:params) { nil }
      it "just returns the application_attrs" do
        expect(result).to eq subject.application_attrs
      end
    end
  end

  describe "#param_attrs" do
    let(:params_values) do
      { assignment_id: 40, score: 50, possible: 60 }
    end

    it "builds a hash from the various params methods" do
      allow(subject).to receive_messages params_values
      expect(subject.param_attrs).to eq params_values
    end
  end

  describe "filtering params attributes" do
    before(:each) { allow(subject).to receive(:params) { params } }

    context "the params exist" do
      # note that the :assignment key is being translated to an :assignment_id
      # method as defined in the .numerical_params method on PredictorEventLogger
      #
      let(:params) do
        { "assignment" => "40", "score" => "50", "possible" => "60" }
      end

      it "returns integers for each of the params methods" do
        expect(subject.assignment_id).to eq 40
        expect(subject.score).to eq 50
        expect(subject.possible).to eq 60
      end
    end

    context "params values don't exist" do
      let!(:params) { { waffles: "70" } }

      it "returns nil for each of the defined param methods" do
        expect(subject.assignment_id).to be_nil
        expect(subject.score).to be_nil
        expect(subject.possible).to be_nil
      end
    end
  end
end
