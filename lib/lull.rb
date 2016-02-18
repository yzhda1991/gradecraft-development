# helpers for performing various tasks relative to the nightly low-usage downtime lull
module Lull
  class << self
    def time_until_next_lull
      next_lull_start - Time.zone.now
    end

    def is_before_todays_lull?
      Time.zone.now < todays_lull_start
    end

    def is_after_todays_lull?
      Time.zone.now > todays_lull_end
    end

    def is_during_todays_lull?
      Time.zone.now > todays_lull_start and
      Time.zone.now < todays_lull_end
    end

    def next_lull_start
      is_after_todays_lull? ? tomorrows_lull_start : todays_lull_start
    end

    def tomorrows_lull_start
      Date.tomorrow.to_time.change(lull_start_params)
    end

    def todays_lull_end
      Time.zone.now.change(lull_end_params)
    end

    def todays_lull_start
      Time.zone.now.change(lull_start_params)
    end

    def lull_start_params
      {hour: 2, min: 30} # zoned to Eastern US and Canada
    end

    def lull_end_params
      {hour: 5, min: 0} # zoned to Eastern US and Canada
    end
  end
end
