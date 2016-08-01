module PartialHelper
  def partial_with(partial, options={}, &block)
    options.merge!({ partial: partial })
    if block_given?
      options[:locals] = {} if options[:locals].nil?
      options[:locals].merge!({ content: block })
    end
    render options
  end
end
