module ConsoleTest
  class Test
    def initialize(attrs={})
      @cycles = attrs[:cycles] || 3
      @start_message = attrs[:start_message] || default_start_message
      @subject = attrs[:subject]
      @actions = [] # this is an array of procs
    end
    attr_accessor :actions, :start_message, :cycles, :subject

    def default_start_message
      "Starting #{cycles} GradebookExporterJob test cycles..."
    end

    def add_action(&action)
      @actions << action
    end

    def attributes
      {
        subject: @subject,
        cycles: @cycles,
        start_message: @start_message
      }
    end

    def run 
      @actions.each do |action|
        subject.call.instance_eval &action
      end
    end
  end
end
