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

        def initialize(export)
          @export = export
          @records = export.export_records
          @parsed_columns = default_columns
        end

        def default_columns
          export.column_names.inject({}) do |memo, column_name|
            memo[column_name] = []
            memo
          end
        end

        # construct a hash that builds an empty array for the default value
        def parse!
          puts "=> Parsing export data by column..."

          export.column_mapping.each do |column_name, parsing_strategy|
            puts "  => parsing column :#{column_name} as :#{parsing_strategy}"

            parsed_columns[column_name] = records.each_with_index.collect do |record, index|
              message = progress_message(index)
              print "    =>#{message.to_s}" if message.printable?

              cell_parser = Parsers::Cell.new \
                strategy: parsing_strategy,
                record: record,
                export: export

              cell_parser.parsed_value
            end
          end
        end

        def progress_message(index)
          Analytics::Export::ProgressMessage.new \
            record_index: index,
            total_records: records.size,
            print_every: 5
        end
      end
    end
  end
end
