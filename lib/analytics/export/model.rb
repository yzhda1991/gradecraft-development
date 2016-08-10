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
      def self.export_mapping(mapping)
        @export_mapping = mapping
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
      attr_accessor :context, :export_records

      def initialize(context:)
        @context = context
      end

      def parsed_export_records
        @parsed_export_records ||= Analytics::Export::RecordParser.new(
          export: self,
          records: export_records
        ).parse_records!
      end

      # let's update the arguments here so that they're at least keyword
      # arguments so we don't have to use nil as a placeholder in the event that
      # we want to use a set of parsed records but not a file_name
      #
      def generate_csv(path, file_name=nil, parsed_export_records=nil)
        Analytics::Export::CSV.new(
          export: self,
          path: path,
          filename: file_name,
          parsed_export_records: parsed_export_records
        ).generate!
      end
    end
  end
end
