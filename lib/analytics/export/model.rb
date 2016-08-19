require "active_support/inflector"

module Analytics
  module Export
    # let's make this a class instead of a module because it's more straight-
    # forward to define the class behaviors that we're using here than it is
    # to include them through the module. Additionally if we need any more
    # common #initialize behaviors here beyond just setting the context on
    # create it's cleaner to use the 'super' keyword to include these
    # behaviors than it is to define them in the #initialize method on
    # each subclass.
    #
    class Model
      # set the hash that defines how each column will be populated with
      # either an attribute on the record-row, or a method that provides
      # additional filtering for the data before populating it
      #
      def self.column_mapping(mapping)
        @column_mapping = mapping
      end

      # define the method that gives us the array of records we'd like to
      # pull from the context to define our export rows.
      #
      def self.export_focus(method_name)
        @export_focus = method_name
      end

      def self.context_filters(*filter_names)
        @context_filters = filter_names
      end

      # every Analytics::Export class will have both a context and a set of
      # export_records. The context is the larger set of records that have
      # been queried for to perform the overall export so that individual
      # queries for the same data don't have to be made if multiple exports
      # are performed.
      #
      # export_records are the set of records that will act as the basis for
      # the data rendered in the CSV by the export itself. Each export_record
      # will represent a row in the final CSV, but that data will be filtered
      # by the export process for a more specific presentation beyond simply
      # rendering the collection of events in its raw form.
      #
      attr_reader :context, :export_records, :filename, :export_focus,
        :column_mapping, :context_filters

      def initialize(context:, filename: nil)
        @context = context
        @filename = filename
        @export_focus = self.class.instance_variable_get :@export_focus
        @column_mapping = self.class.instance_variable_get :@column_mapping
        @export_records = context.send(export_focus) if export_focus
      end

      def parsed_columns
        @parsed_columns ||= Analytics::Export::Parsers::Column.new(self).parse!
      end

      # reorganize the data by column into rows by transposing the values
      def parsed_rows
        return nil unless parsed_columns
        @parsed_rows ||= parsed_columns.values.transpose
      end

      # generate a 'header' row for the CSV file by pulling the column names
      # from the schema that we defined with set_schema
      def column_names
        column_mapping ? column_mapping.keys : []
      end

      def default_filename
        "#{self.class.name.underscore}.csv"
      end

      # build a hash of context filters according to the class prefixes we've
      # defined in ClassName.context_filters.
      #
      # Individual filters will be fetchable as context_filters[:filter_name],
      # which is intended to feel like a params[] object in a rails controller
      #
      def context_filters
        filter_names = self.class.instance_variable_get :@context_filters

        @context_filters ||= filter_names.inject({}) do |memo, filter_name|
          # re-add the context_filter suffix when we're fetching the class
          filter_class = "#{filter_name}_context_filter".camelize.constantize

          # build the filter instance using the context
          memo[filter_name] = filter_class.new(context)
          memo
        end
      end

      def write_csv(directory_path)
        csv_filepath = File.join directory_path, (filename || default_filename)

        ::CSV.open(csv_filepath, "wb") do |csv|
          # add the header names for each column
          csv << column_names

          # add all of the rows
          parsed_rows.each {|row| csv << row }
        end
      end
    end
  end
end
