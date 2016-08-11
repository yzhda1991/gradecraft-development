module Analytics
  module Export

    # This class is used to build a hash of all final values for the records
    # that have been designated for export in the containing
    # Analytics::Export::Mdoel class.
    #
    # The result of #parse_records! will produce a hash of parsed arrays in
    # which each
    #
    # {
    #   username: ["dave_b", "anne_c", "karen_w"],
    #   role: ["admin", "owner", "owner"], ...
    # }
    #
    module Parsers
      class Column
        attr_reader :export, :records, :parsed_columns

        def initialize(export:, records:)
          @export = export
          @records = records
          @parsed_columns = default_columns
        end

        # get the column mapping that's defined on the export class
        #
        def column_mapping
          export.class.column_mapping
        end

        def default_columns
          export.column_names.inject({}) do |memo, column_name|
            memo[column_name] = []
            memo
          end
        end

        # construct a hash that builds an empty array for the default value
        def parse!
          puts " => Parsing export data by column..."

          column_mapping.each do |column_name, parsing_strategy|
            puts "    => parsing column :#{column_name} as :#{parsing_strategy}"

            parsed_columns[column_name] = records.each_with_index.collect do |record, index|
              message = progress_message(index)
              print message.formatted_message if message.printable?

              cell = Parsers::Cell.new \
                strategy: parsing_strategy,
                record: record,
                export: export

              cell_parser.parsed_value
            end
          end
        end

        def progress_message(index)
          Analytics::Export::Message.new \
            record_index: index,
            total_records: records.size
        end
      end
    end
  end
end
