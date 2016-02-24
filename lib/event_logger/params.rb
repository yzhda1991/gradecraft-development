module EventLogger
  # this module is responsible for adding methods to an event logger that takes
  # param values from the event_session or controller and needs to format or
  # filter them prior to passing them into a given Analytics class.
  module Params
    # param_schema here should be in the format of:
    #
    # :input_value => :output_value
    #
    # where :input_value is the actual key in the params hash, and
    # :output_value is the key that will be given in the output for
    # EventLogging
    #
    # this defines filtering methods for all of the keys that will be taken out
    # of the params hash. If the value is a symbol, then a method will be
    # defined using the same name as the params key. If a hash is given, it
    # will define a method using the name of the hash value, and expects the
    # same key name that was used in the params hash.
    #
    # Here is an example of conditionally defining context for each parameter:
    #
    # numerical_params :score, :possible, { :assignment => :assignment_id }
    def numerical_params(*param_schema)
      param_schema.each do |param_format|
        # if it's a symbol, just define a method with the same name as the
        # input param
        if param_format.is_a?(Symbol)
          define_filtered_numerical_param(param_format)

        # if the format is a hash, define a method with the name of the value,
        # and expect that the key will be the same as the param key
        elsif param_format.is_a?(Hash)
          param_format.each do |input_name, output_name|
            define_filtered_numerical_param(input_name, output_name)
          end

        end
      end
    end

    # this method is responsible for actually defining the method on the event
    # logger that ultimately does the work in either filtering the given
    # params, or returning nil rather than zero if no value exists for the
    # given param
    def define_filtered_numerical_param(input_name, output_name = nil)
      # if an output name is given, use that for the method_name, otherwise
      # just define a method with the same name as the param
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
