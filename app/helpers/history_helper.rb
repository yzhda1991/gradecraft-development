require "./lib/historical"

module HistoryHelper
  def history(changesets)
    content_tag(:div) do
      changesets.collect do |changeset|
        concat content_tag(:div, build_sentence(changeset))
      end
    end
  end

  private

  def assemble_sentence(structure)
    "#{structure[:actor]} #{structure[:event]} #{structure[:change]} on #{structure[:date]} at #{structure[:time]}"
  end

  def build_sentence(changeset)
    tokenizer = Historical::HistoryTokenizer.new(changeset)
    assemble_sentence Historical::HistoryTokenParser.new(tokenizer).parse(current_user: current_user)
  end
end
