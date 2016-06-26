#
# the raison d'être of this class is that we're not necessarily sure how we're
# going to be getting export data out of a given record, or what objects and
# method names we're being given.
#
# this helps us take the various pieces of information that have and ferret
# through them to export a correctly-parsed hash of schema records to
# store in Mongo
#
module Analytics
  module Export
    class ExportRecord
      attr_reader :parsing_method, :record, :export

      def initialize(parsing_method:, record:, export:)
        @parsing_method = parsing_method
        @record = record
        @export = export
      end

      def parsed_value
        # if the parsing method is a proc, then pass the record into it to get
        # our parsed value
        #
        return parse_value_with_proc if parsing_method_is_proc?

        # if the record we've designated for export has the attribute that we've
        # defined as the parsing_method in our export_mapping, then just call the
        # method on the record directly to get the value
        #
        return use_record_method if record_has_parsing_method?

        # if the parsing_method is not a proc, and the record does not have a
        # method named for the value of #parsing_method, then give us the value of
        # a method on the export class itself if it has one
        return use_export_method if export_has_parsing_method?

        # if none of these things are true then we've probably made a mistake
        # and no value can be found for the parsing method we've passed in.
        #
        # let's raise an error to alert our developers that we've made a mistake
        # somewhere along the way.
        #
        raise Analytics::Errors::InvalidParsingMethod, [export, parsing_method]
      end

      def parsing_method_is_proc?
        # this will only work if the parsing method is a proc or a lambda.
        # This allows us to define Procs and Lambda values in the schema
        # rather than defining methods if that feels more straightforwrad.
        #
        parsing_method.respond_to? :call
      end

      def parse_value_with_proc
        parsing_method.call record
      end

      def record_has_parsing_method?
        record.respond_to? parsing_method
      end

      # just call the
      def use_record_method
        record.send parsing_method
      end

      def export_has_parsing_method?
        export.respond_to? parsing_method
      end

      # if all else has failed the target must be a method on the export itself,
      # so let's send it the record as an argument
      #
      def send_export_method
        export.send parsing_method, record
      end
    end
  end
end
