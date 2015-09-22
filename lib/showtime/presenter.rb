module Showtime
  class Presenter
    def self.build(args={})
      new(args).render_options
    end

    def initialize(args={})
      @properties = args
    end

    def properties
      @properties ||= {}
    end

    def render_options
      { locals: { presenter: self } }
    end
  end
end
