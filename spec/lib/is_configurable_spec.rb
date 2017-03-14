describe IsConfigurable, type: :vendor_library do
  include Toolkits::Lib::IsConfigurableToolkit::SharedExamples

  # this is a mock configuration intended to match the configurable attributes
  # for the target class in which IsConfigurable is included
  demo_config = {
    waffle_name: "blueberry",
    pancake_size: 30
  }

  it_behaves_like "it is configurable", IsConfigurableTestClass, demo_config
end
