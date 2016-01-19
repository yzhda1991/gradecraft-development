require "./lib/collection_merger"

module Historical
  extend ActiveSupport::Concern

  included do
    has_paper_trail
  end

  def has_history?
    !history.empty?
  end

  def history
    self.versions.reverse.map do |version|
      changeset = version.changeset.dup
      changeset.merge!("object" => self.class.name)
      changeset.merge!("event" => version.event)
      changeset.merge!("actor_id" => version.whodunnit)
      changeset.merge!("recorded_at" => version.created_at)
    end
  end

  def historical_merge(historical_model)
    return self.history if historical_model.nil?

    CollectionMerger.new(self.history, historical_model.history)
      .merge(field: ->(version) { version["recorded_at"] }, order: :desc)
  end
end
