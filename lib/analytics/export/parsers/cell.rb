#
# the raison d'être of this class is that we're not necessarily sure how we're
# going to be getting export data out of a given record, or what objects and
# strategy names we're being given.
#
# this helps us take the various pieces of information that have and ferret
# through them to export a correctly-parsed hash of schema records to
# store in Mongo
#
module Analytics
  module Export
    module Parsers
      class Cell
        attr_reader :parsing_strategy, :record, :export

        def initialize(parsing_strategy:, record:, export:)
          @parsing_strategy = parsing_strategy
          @record = record
          @export = export
        end

        def parsed_value
          # if the export has a method name that matches the parsing_strategy,
          # let's try that first
          #
          return export_strategy if export.respond_to? parsing_strategy

          # otherwise see if the record itself has an attribute that matches
          # the parsing strategy
          #
          return record_strategy if record.respond_to? parsing_straegy

          # if neither of these exist then we've probably made a mistake in
          # defining our column_mapping. let's raise an error so know about it
          #
          raise Analytics::Errors::InvalidParsingStrategy.new \
            parsing_strategy: parsing_strategy,
            record: record,
            export: export
        end

        # just call the method on the record itself
        def record_strategy
          record.send parsing_strategy
        end

        # if all else has failed the target must be a strategy on the export itself,
        # so let's send it the record as an argument
        #
        def export_strategy
          export.send parsing_strategy, record
        end
      end
    end
  end
end
