module ConsoleTest
  class TestRunner
    def initialize(attrs={})
      @tests = []
      @subject = nil
      @cycles = attrs[:cycles] || 3
      @start_message = attrs[:start_message] || default_start_message
    end
    attr_reader :runner, :attrs, :cycles
    attr_accessor :tests, :subject, :start_message

    def default_start_message
      "Starting #{cycles} ConsoleTest cycles..."
    end

    def subject(&new_subject)
      @subject = new_subject
    end

    def start
      @tests.each do |test|
        puts test.start_message
        test.cycles.times { test.run }
      end
    end

    def default_test_attrs
      {
        subject: @subject,
        cycles: @cycles,
        start_message: @start_message
      }
    end

    def add_test(&action_block)
      console_test = ConsoleTest::Test.new(default_test_attrs)
      console_test.actions << action_block if action_block
      @tests << console_test
      console_test
    end
  end
end
