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

    def object_key_microseconds
      filename_time.to_f.to_s.tr(".","")
    end

    def object_key_date
      filename_time.strftime("%F")
    end

    def filename_time
      # if we need to generate a new filename for some reason, use the created_at
      # date, otherwise let's presume this is a new export and just use Time.now
      # for parsing a date in the format YYYY-MM-DD
      @filename_time ||= created_at || Time.now
    end

    def filename_timestamp
      filename_time.strftime "%Y-%m-%d - %l%M%p"
    end

    def downloadable?
      !!last_export_completed_at
    end
  end
end
