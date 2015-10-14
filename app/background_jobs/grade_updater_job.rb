class GradeUpdaterJob < ResqueJob::Base
  @queue = :grade_updater
  @performer_class = GradeUpdatePerformer
  @logger = Logglier.new("https://logs-01.loggly.com/inputs/#{ENV['LOGGLY_TOKEN']}/tag/grade-updater-job-queue", threaded: true, format: :json)

  def self.perform(attrs={})
    begin
      p self.start_message(attrs) # this wasn't running because 
      @logger.info self.start_message(attrs) # this wasn't running because 

      # this is where the magic happens
      puts "building a new performer"
      performer = @performer_class.new(attrs) # self.class is the job class
      puts "doing the work"
      performer.do_the_work
      puts performer
      puts "done working"

      
      performer.outcomes.each do |outcome|
        outcome_messages = []
        outcome_messages << "SUCCESS: #{outcome.message}" if outcome.success?
        outcome_messages << "FAILURE: #{outcome.message}" if outcome.failure?
        outcome_messages << "RESULT: " + "#{outcome.result}"[0..100].split("\n").first
        final_message = outcome_messages.join("\n")
        puts final_message
        @logger.info final_message
        @logger.info "RESULT TEST: " + "#{outcome.result}"[0..100].split("\n").first
        @logger.info "SUCCESS TEST: #{outcome.message}" if outcome.success?
      end

    rescue Exception => e
      @logger.info "Error in #{@performer_class.to_s}: #{e.message}"
      @logger.info e.backtrace.inspect
      # puts e.backtrace.inspect
      raise ResqueJob::ForcedRetryError
    end
  end
end
