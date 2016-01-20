module HumanHistory
  class DefaultMergeStrategy
    attr_reader :left, :right

    def initialize(left, right)
      @left = left
      @right = right
    end

    def merge!(options={})
      strategy = options[:strategy]
      "#{left} #{strategy} #{right}"
    end
  end
end
