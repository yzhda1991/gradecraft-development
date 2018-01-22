class QueueScoreRecalculatorJob
  @queue = :nightly_score_recalculator

  def self.perform
    # TODO: Discuss logic by which we might want to filter down courses
    # At the moment, we filter by active courses but it doesn't seem like we are
    # reliably deactivating courses
    Course.active.in_batches(of: 100) do |batch|
      batch.each(&:recalculate_student_scores)
    end
  end
end
