class CollectionMerger
  attr_reader :left, :right

  def initialize(left, right)
    @left = left
    @right = right
  end

  def merge(options={})
    opts = default_options.merge options

    return left if right.nil?

    merged = left | right
    merged.sort! { |l, r| value_of(l, opts[:field]) <=> value_of(r, opts[:field]) }
    merged.reverse! if opts[:order] == :desc
    merged
  end

  private

  def default_options
    { field: :created_at, order: :asc }.freeze
  end

  def value_of(obj, field)
    if field.respond_to? :call
      field.call(obj)
    else
      obj.send(field)
    end
  end
end
