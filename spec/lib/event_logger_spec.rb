describe EventLogger, type: :vendor_library do
  include Toolkits::Lib::IsConfigurableToolkit::SharedExamples

  # this is a mock configuration intended to match the configurable attributes
  # for the target class in which IsConfigurable is included
  demo_config = {
    backoff_strategy: [5, 6, 7]
  }

  it_behaves_like "it is configurable", EventLogger, demo_config
end
