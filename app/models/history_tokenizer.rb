require_relative "actor_history_token"
require_relative "change_history_token"
require_relative "date_history_token"
require_relative "event_history_token"
require_relative "time_history_token"

class HistoryTokenizer
  attr_reader :changeset, :tokens, :type

  def initialize(changeset)
    @changeset = changeset
    @type = changeset["object"]
    @tokens = []
    register
  end

  def tokenize
    changeset.each do |key, value|
      tokens << HistoryTokenRegistry.for(key, value, changeset)
        .map { |t| t.create(key, value, type) }
    end
    tokens.flatten!

    self
  end

  private

  def register
    HistoryTokenRegistry.register ActorHistoryToken
    HistoryTokenRegistry.register DateHistoryToken
    HistoryTokenRegistry.register TimeHistoryToken
    HistoryTokenRegistry.register EventHistoryToken
    HistoryTokenRegistry.register ChangeHistoryToken
  end
end
