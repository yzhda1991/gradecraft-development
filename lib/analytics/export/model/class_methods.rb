module Analytics
  module Export
    module Model
      # This hasn't been changed at all, it's just been moved from
      # Analytics::Export to Analtyics::Export::Model::ClassMethods so that we
      # can use the ::Export module to house adjacent helper classes.
      #
      # This entire process is the subject of the 2132 branch/issue, and has been
      # completely refactored into multiple classes on that branch for
      # significantly better readability and clarity of process.

      module ClassMethods
        def set_schema(schema_hash)
          @schema = schema_hash
        end

        def schema
          @schema
        end

        def rows_by(collection)
          @rows = collection
        end

        def rows
          @rows
        end
      end
    end
  end
end
