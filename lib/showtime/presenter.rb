module Showtime
  class Presenter
    def self.build(args={})
      new(args).render_options
    end

    def initialize(args={})
      @properties = symbolize_keys args
    end

    def properties
      @properties ||= {}
    end

    def params
      properties[:params]
    end

    def render_options
      { locals: { presenter: self } }
    end

    def self.wrap(collection, model_name, args={})
      collection.collect do |item|
        arguments = args.merge({ "#{model_name.to_sym}" => item })
        self.new(arguments)
      end
    end

    private

    def symbolize_keys(hash)
      hash.inject({}) { |memo, (k, v)| memo[k.to_sym] = v; memo }
    end
  end
end
