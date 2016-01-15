class CollectionMerger
  attr_reader :left, :right

  def initialize(left, right)
    @left = left
    @right = right
  end

  def merge(options={})
    opts = default_options.merge options

    merged = left | right
    merged.sort! { |l, r| l.send(opts[:field]) <=> r.send(opts[:field]) }
    merged.reverse! if opts[:order] == :desc
    merged
  end

  private

  def default_options
    { field: :created_at, order: :asc }.freeze
  end
end
