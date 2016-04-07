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
    @history ||= self.versions.reverse.map do |version|
      history = HistoryItem.new(version)
      history.changeset.merge!("object" => self.class.name,
                               "event" => version.event,
                               "actor_id" => version.whodunnit,
                               "recorded_at" => version.created_at)
      history
    end
  end

  def historical_merge(historical_model)
    return self if historical_model.nil?

    self.history = CollectionMerger.new(self.history, historical_model.history)
      .merge(field: ->(history) { history.changeset["recorded_at"] },
             order: :desc)
    self
  end

  def historical_collection_merge(historical_collection)
    return self if historical_collection.nil? || historical_collection.empty?

    historical_collection.each { |historical_model| historical_merge(historical_model) }
    self
  end

  def squish_history!
    current_version = self.versions.last
    previous_version = self.versions[-2]

    if previous_version
      current = PaperTrail.serializer.load(current_version.object)
      current_version.changeset.each do |attribute, changes|
        current[attribute] = changes.last
      end
      current_version.object = PaperTrail.serializer.dump(current)

      changeset = previous_version.changeset.merge current_version.changeset
      current_version.instance_variable_set "@changeset", changeset
      current_version.save

      previous_version.destroy!
    end
  end

  private

  def history=(history)
    @history = history
  end
end
