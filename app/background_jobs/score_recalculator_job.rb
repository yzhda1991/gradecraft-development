# TODO: add specs for all of these
class ScoreRecalculatorJob < ResqueJob::Base
  @queue = :score_recalculator
  @performer_class = ScoreRecalculatorPerformer
  @logger = Logglier.new("https://logs-01.loggly.com/inputs/#{ENV['LOGGLY_TOKEN']}/tag/score-recalculator-job-queue", threaded: true, format: :json)
end
