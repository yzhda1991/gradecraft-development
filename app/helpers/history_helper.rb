require "./lib/human_history"

module HistoryHelper
  def history(changesets)
    content_tag(:div) do
      changesets.collect do |changeset|
        concat content_tag(:div, build_sentence(changeset))
      end
    end
  end

  def history_timeline(changesets)
    content_tag(:section, nil, id: "history-timeline", class: "timeline-container") do
      changesets.collect do |changeset|
        concat history_timeline_block changeset
      end
    end
  end

  def history_timeline_block(changeset)
    content_tag(:div, history_timeline_content(changeset), class: "timeline-block")
  end

  def history_timeline_content(changeset)
    classname = changeset["object"].underscore.dasherize
    image = content_tag(:div, nil, class: "timeline-img timeline-#{classname}") do
      concat content_tag(:i, nil, class: "fa icon-#{classname} fa-fw fa-lg centered")
    end

    content = content_tag(:div, nil, class: "timeline-content") do
      concat content_tag(:h2, "#{changeset["object"].humanize} #{changeset["event"]}d")
      concat history_timeline_list(changeset)
      concat content_tag(:span, changeset["recorded_at"], class: "timeline-date")
    end
    image + content
  end

  def history_timeline_list(changeset)
    structure = tokenize_sentence changeset, merge_strategy: :array
    content_tag(:ul, nil) do
      item = "#{structure[:actor]} #{structure[:event]}"
      [structure[:change]].flatten.each do |change|
        concat content_tag :li, "#{item} #{change}".html_safe
      end
    end
  end

  private

  def assemble_sentence(structure)
    "#{structure[:actor]} #{structure[:event]} #{structure[:change]} on #{structure[:date]} at #{structure[:time]}"
  end

  def build_sentence(changeset)
    assemble_sentence tokenize_sentence(changeset)
  end

  def tokenize_sentence(changeset, options={})
    tokenizer = HumanHistory::HistoryTokenizer.new(changeset)
    HumanHistory::HistoryTokenParser.new(tokenizer).parse({ current_user: current_user }.merge(options))
  end
end
