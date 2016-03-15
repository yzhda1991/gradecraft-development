module KeywordArguments
  # This will define all keyword arguments passed into the containing
  # __method__ as ivars. This allows the keyword arguments in the target method
  # to change without having to worry about explicitly changing which attributes
  # are being defined.
  #
  module DefineAsIvars
    method(__method__).parameters.each do |type, key|
      next unless type == :key
      value = eval(key.to_s)
      instance_variable_set("@#{key}", value) unless value.nil?
    end
  end
end
