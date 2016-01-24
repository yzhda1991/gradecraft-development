module HumanHistory
  class ArrayMergeStrategy
    attr_reader :left, :right

    def initialize(left, right)
      @left = left
      @right = right
    end

    def merge!(options={})
      ([left] + [right]).flatten
    end
  end
end
