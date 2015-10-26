# TODO: add specs for all of these
class ScoreRecalculatorJob < ResqueJob::Base
  @queue = :score_recalculator
  @performer_class = ScoreRecalculatorPerformer
end
