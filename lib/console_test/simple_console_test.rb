module ConsoleTest:: SimpleConsoleTest
  class SimpleConsoleTest
    def initialize(subject_block)
      @subject_block = subject_block
    end

    def subject
      @subject_block.call
    end

    def start_message
      "RUNNING THE #{self.class} TEST #{@cycles} TIMES"
    end

    def run(attrs={}, &subject_block)
      initialize(subject_block)
    end
  end
end

# class SomeTest < ConsoleTest::SimpleConsoleTest
#
