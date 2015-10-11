require_relative '../test_helper'

module GradebookExporterTest
  class TestRunner
    def initialize(attrs={})
      @tests = []
      @attrs = attrs
      @cycles = @attrs[:cycles] || 3
      @start_message = @attrs[:start_message] || default_start_message
    end
    attr_reader :runner, :attrs, :cycles
    attr_accessor :tests

    def default_start_message
      "Starting #{cycles} GradebookExporterJob test cycles..."
    end

    def start
      @tests.each do |test|
        puts test.start_message
        test.cycles.times { test.run }
      end
    end

    def add_test(&action_block)
      console_test = ConsoleTest.new(@attrs)
      console_test.actions << action_block if action_block
      @tests << console_test
      console_test
    end
  end

  class ConsoleTest
    def initialize(attrs={})
      @attrs = attrs
      @cycles = @attrs[:cycles] || 3
      @start_message = @attrs[:start_message] || default_start_message
      @actions = [] # this is an array of procs
    end
    attr_accessor :actions, :start_message, :cycles

    def subject
      GradebookExporterJob.new(subject_attrs)
    end

    def subject_attrs
      { user_id: 1, course_id: 3 }
    end

    def default_start_message
      "Starting #{cycles} GradebookExporterJob test cycles..."
    end

    def run 
      @actions.each do |action|
        subject.instance_eval &action
      end
    end
  end
end

@test_runner = GradebookExporterTest::TestRunner.new

@enqueue_test = @test_runner.add_test { enqueue }
@enqueue_test.start_message = "Running normal enqueues, should happen right now:"

@enqueue_in_test = @test_runner.add_test { enqueue_in(10) }
@enqueue_in_test.start_message = "Running delayed enqueue_in calls, should happen in ten seconds:"

@test_runner.start
