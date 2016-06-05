module Analytics
  module Export
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
