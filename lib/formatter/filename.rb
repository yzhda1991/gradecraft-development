module Formatter
  class Filename
    include ActiveSupport::Inflector

    def initialize(filename)
      @original_filename = @filename = filename
    end

    attr_accessor :filename, :original_filename

    def sanitize
      self.filename = filename
        .downcase
        .gsub(/[^\w\s_\:-]+/, " ") # strip out characters besides letters and digits
        .gsub(/[_\ ]+/, "_") # replace multiple spaces or underscores with single underscores
        .gsub(/\A[_\ -]+/, "") # remove leading characters \A signifies leading
        .gsub(/[_\ -]+\z/, "") # remove trailing characters, \z signifies trailing
      self
    end

    def reset!
      self.filename = original_filename
    end

    class << self
      # available ActiveSupport::Inflector behaviors
      def inflector_methods
        [:camelize, :classify, :constantize, :dasherize, :deconstantize,
         :humanize, :ordinalize, :parameterize, :pluralize, :singularize,
         :tableize, :titleize, :underscore]
      end

      # add chaining behaviors for inflector methods
      inflector_methods.each do |inflector_method|
        define_method inflector_method do |filename|
          self.new(filename).sanitize.send(inflector_method).filename
        end
      end
    end

    # add chaining behaviors for inflector methods
    inflector_methods.each do |inflector_method|
      # if there's no exclamation return the object
      define_method inflector_method do
        self.filename = filename.send(inflector_method)
        self
      end

      # if there's an exclamation return the filename
      define_method "#{inflector_method}!" do
        self.filename = filename.send(inflector_method)
        filename
      end
    end
  end
end
