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
      attr_reader :target, :record, :export

      def initialize(target:, record:, export:)
        @target = target
        @record = record
        @export = export
      end

      def get_value
        return call_target_method if target_is_a_method?
        return record_attribute if record_has_attribute?
        return send_export_method if export_has_method?
      end

      def target_is_a_method?
        # this will only work if the target is an uncalled method
        target.respond_to? :call
      end

      def call_target_method
        target.call record
      end

      def record_has_attribute?
        record.respond_to? target
      end

      def record_attribute
        record.send target
      end

      def export_has_method?
        export.respond_to? target
      end

      # if all else has failed the target must be a method on the export itself,
      # so let's send it the record as an argument
      def send_export_method
        export.send target, record
      end
    end
  end
end
