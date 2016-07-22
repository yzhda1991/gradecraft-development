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

    def key_generated_at_in_microseconds
      return unless created_at
      key_generated_at.to_f.to_s.tr(".","")
    end

    def key_generated_at_date
      return unless created_at
      key_generated_at.strftime("%F")
    end

    def key_generated_at
      @key_generated_at ||= created_at || Time.now
    end

    def downloadable?
      !!last_export_completed_at
    end
  end
end
