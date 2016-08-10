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
    class ExportRecord
      attr_reader :parsing_strategy, :record, :export

      def initialize(parsing_strategy:, record:, export:)
        @parsing_strategy = parsing_strategy
        @record = record
        @export = export
      end

      def parsed_value
        # if the parsing_strategy is not a proc, and the record does not have a
        # strategy named for the value of #parsing_strategy, then give us the value of
        # a strategy on the export class itself if it has one
        return use_export_strategy if export_has_parsing_strategy?

        # if the record we've designated for export has the attribute that we've
        # defined as the parsing_strategy in our export_mapping, then just call the
        # strategy on the record directly to get the value
        #
        return use_record_strategy if record_has_parsing_strategy?

        # if none of these things are true then we've probably made a mistake
        # and no value can be found for the parsing strategy we've passed in.
        #
        # let's raise an error to alert our developers that we've made a mistake
        # somewhere along the way.
        #
        raise Analytics::Errors::InvalidParsingStrategy.new \
          parsing_strategy: parsing_strategy,
          record: record,
          export: export
      end

      def record_has_parsing_strategy?
        record.respond_to? parsing_strategy
      end

      def export_has_parsing_strategy?
        export.respond_to? parsing_strategy
      end

      # just call the
      def use_record_strategy
        record.send parsing_strategy
      end

      # if all else has failed the target must be a strategy on the export itself,
      # so let's send it the record as an argument
      #
      def send_export_strategy
        export.send parsing_strategy, record
      end
    end
  end
end
