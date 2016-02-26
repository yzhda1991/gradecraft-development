require "logglier"
require_relative "../../lib/loggly_resque"
require_relative "../toolkits/lib/loggly_resque/shared_examples"
require_relative "../support/test_classes/lib/loggly_resque/loggly_resque_test"

describe LogglyResque, type: :vendor_library do
  include Toolkits::Lib::LogglyResqueToolkit::SharedExamples

  it_behaves_like "the #logger is implemented through Logglier with LogglyResque", LogglyResqueTest
end
