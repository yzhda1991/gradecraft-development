require_relative "model/class_methods"

module Analytics
  module Export
    module Model
      def self.included(base)
        attr_accessor :loaded_data
        base.extend Analytics::Export::ClassMethods

        base.class_eval do
          attr_accessor :data
        end
      end

      def initialize(loaded_data)
        self.data = loaded_data
      end

      def initialize(loaded_data)
        @loaded_data = loaded_data
      end

      def records
        @records ||= loaded_data[self.class.rows]
      end

      def parsed_schema_records(records_set=nil)
        @parsed_schema_records ||= Analytics::Export::RecordParser.new(
          export: self,
          records: records_set || records
        ).parse_records!
      end

      def generate_csv(path, file_name=nil, schema_record_set=nil)
        Analytics::Export::CSV.new(
          export: self,
          path: path,
          filename: file_name,
          schema_record_set: schema_record_set
        ).generate!
      end
    end
  end
end
