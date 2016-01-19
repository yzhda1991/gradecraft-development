class HistoryFilter
  attr_reader :changeset

  def initialize(changeset)
    @changeset = changeset
  end

  def exclude(options={})
    exclusions = options.keys

    @changeset = changeset.select do |set|
      result = exclusions.inject(true) do |select, exclusion|
        set[exclusion] != options[exclusion]
      end
      result &= !yield(set) if block_given?
      result
    end.delete_if { |set| empty_changeset?(set) }
    self
  end

  def include(options={})
    inclusions = options.keys
    @changeset = changeset.select do |set|
      result = inclusions.inject(true) do |select, inclusion|
        set[inclusion] == options[inclusion]
      end
      result &= yield(set) if block_given?
      result
    end.delete_if { |set| empty_changeset?(set) }
    self
  end

  def remove(options)
    name = options["name"]

    @changeset = changeset.map do |set|
      set.delete_if { |key, value| name == key } if name
    end.delete_if { |set| empty_changeset?(set) }
    self
  end

  def empty_changeset?(set)
    set.values.none? { |value| value.is_a? Array }
  end
end
