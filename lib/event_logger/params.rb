module EventLogger
  module Params
    # param_schema here should be in the format of :input_value => :output_value,
    # where :input_value is the actual key in the params hash, and :output_value is
    # the key that will be given in the output for EventLogging

    # conditionally define methods for each parameter
    def numerical_params(*param_schema)
      param_schema.each do |param_format|

        # if it's a symbol, just define a method with the same name as the input param
        if param_format.is_a?(Symbol)
          define_filtered_numerical_param(param_format)

        # if the format is a hash, define a method with the name of the value, and
        # expect that the key will be the same as the param key
        elsif param_format.is_a?(Hash)
          param_format.each do |input_name, output_name|
            define_filtered_numerical_param(input_name, output_name)
          end

        end
      end
    end

    def define_filtered_numerical_param(input_name, output_name=nil)
      # if an output name is given, use that for the method_name, otherwise just define a
      # method with the same name as the param
      method_name = output_name ? output_name : input_name

      define_method method_name do
        # if the param with the input name exists in the hash
        if params[input_name]
          # then return the value as an integer
          params[input_name].to_i
        end
      end
    end
  end
end
