describe LogglyResque, type: :vendor_library do
  include Toolkits::Lib::LogglyResqueToolkit::SharedExamples

  it_behaves_like "the #logger is implemented through Logglier with LogglyResque", LogglyResqueTest
end
