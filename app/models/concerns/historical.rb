require "./lib/collection_merger"

module Historical
  extend ActiveSupport::Concern

  class HistoryItem
    attr_accessor :changeset
    attr_reader :version

    def initialize(version)
      @version = version
      @changeset = @version.changeset.dup
    end
  end

  included do
    has_paper_trail
  end

  def has_history?
    !history.empty?
  end

  def history
    self.versions.reverse.map do |version|
      history = HistoryItem.new(version)
      history.changeset.merge!("object" => self.class.name,
                               "event" => version.event,
                               "actor_id" => version.whodunnit,
                               "recorded_at" => version.created_at)
      history
    end
  end

  def historical_merge(historical_model)
    return self.history if historical_model.nil?

    CollectionMerger.new(self.history, historical_model.history)
      .merge(field: ->(history) { history.changeset["recorded_at"] },
             order: :desc)
  end
end
