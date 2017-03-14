describe Analytics, type: :vendor_library do
  include Toolkits::Lib::IsConfigurableToolkit::SharedExamples

  # this is a mock configuration intended to match the configurable attributes
  # for the target class in which IsConfigurable is included
  demo_config = {
    event_aggregates: {
      predictor: ["some_constant_here_actually"]
    },
    default_granularity_options_for_select: [
      ["Monthly", :monthly],
      ["Weekly", :weekly]
    ],
    default_range_options_for_select: [
      ["Past Day", "past_day"],
      ["Past Year", "past_year"]
    ],
    exports: ["some_other_constant_here"]
  }

  it_behaves_like "it is configurable", Analytics, demo_config
end
