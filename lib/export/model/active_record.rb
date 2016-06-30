module Export
  module Model
    module ActiveRecord
      def update_export_completed_time
        update_attributes last_export_completed_at: Time.now
      end

      def created_at_in_microseconds
        return unless created_at
        created_at.to_f.to_s.tr(".","")
      end

      def created_at_date
        return unless created_at
        created_at.strftime("%F")
      end

      def downloadable?
        !!last_export_completed_at
      end
    end
  end
end
