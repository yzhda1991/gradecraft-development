module Export
  module Model
    def update_export_started_time
      update_attributes last_export_started_at: Time.now,
        last_completed_step: nil
    end

    def update_export_completed_time
      update_attributes last_export_completed_at: Time.now,
        last_completed_step: "complete"
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
