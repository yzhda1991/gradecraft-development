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
    "#{structure[:actor]} changed #{structure[:change]} on #{structure[:date]} at #{structure[:time]}"
  end

  def assemble_structure(structure)
    assemble_sentence structure.delete_if(&:nil?).reduce Hash.new, :merge
  end

  def build_sentence(changeset)
    assemble_structure changeset.collect { |key, value| build_sentence_structure(key, value) }
  end

  def build_sentence_structure(key, value)
    return build_actor(value) if key == "actor_id"
    return build_updated_at(value) if key == "updated_at"
    build_changes(key, value) if value.is_a? Array
  end

  def build_actor(actor_id)
    user = User.where(id: actor_id).first
    { actor: user.name }
  end

  def build_changes(attribute, changes)
    { change: "the #{attribute} from \"#{changes.first}\" to \"#{changes.last}\"" }
  end

  def build_updated_at(value)
    datetime = value.last
    { date: datetime.strftime("%B #{datetime.day.ordinalize}, %Y"),
      time: datetime.strftime("%-I:%M %p") }
  end
end
