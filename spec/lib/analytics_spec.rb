require_relative '../../lib/is_configurable'
require_relative '../toolkits/lib/is_configurable/shared_examples'

describe Analytics, type: :vendor_library do
  include Toolkits::Lib::IsConfigurableToolkit::SharedExamples

  # this is a mock configuration intended to match the configurable attributes
  # for the target class in which IsConfigurable is included
  demo_config = {
    event_aggregates: {
      predictor: [
        "some_constant_here_actually"
      ]
    },
    default_granularity_options_for_select: ,
    default_range_options_for_select: [['Past Day', 'past_day']],
    exports: []
  }

  it_behaves_like "it is configurable", Analytics, demo_config
end
