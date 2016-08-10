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
        attr_reader :export, :records

        def initialize(export:, records:)
          @export = export
          @records = records
        end

        # get the column mapping that's defined on the export class
        #
        def column_mapping
          export.class.column_mapping
        end

        # construct a hash that builds an empty array for the default value
        def parse!
          puts " => Parsing export data by column..."

          Hash.new {|hash, key| hash[key] = [] }.tap do |parsed_columns|
            # iterate over the export mapping format defined in the export class
            # that subclassed Analytics::Export::Model
            #
            column_mapping.each do |column_name, parsing_strategy|
              # we're inspecting these because it's possible that we might have a
              # Proc or a different class altogether for the parsing_method
              #
              puts "    => parsing column #{column_name.inspect} as #{parsing_strategy.inspect}"

              parsed_columns[column_name] = records.each_with_index.collect do |record, index|
                # print messages for our records on output so we can keep track of
                # our progress
                #
                message = Message.new \
                  record_index: index,
                  total_records: records.size
                print message.formatted_message if message.printable?

                schema_record = Parsers::Cell.new \
                  strategy: parsing_strategy,
                  record: record,
                  export: export

                schema_record.parsed_value
              end
            end
          end
        end

      end
    end
  end
end
