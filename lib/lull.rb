# helpers for performing various tasks relative to the nightly low-usage
# downtime lull
module Lull
  class << self
    def time_until_next_lull
      next_lull_start - Time.zone.now
    end

    def before_todays_lull?
      Time.zone.now < todays_lull_start
    end

    def after_todays_lull?
      Time.zone.now > todays_lull_end
    end

    def during_todays_lull?
      Time.zone.now > todays_lull_start &&
        Time.zone.now < todays_lull_end
    end

    def next_lull_start
      after_todays_lull? ? tomorrows_lull_start : todays_lull_start
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

    # define the zoned hour and minute at which the lull is
    # scheduled to begin
    def lull_start_params
      { hour: 2, min: 30 }
    end

    # define the zoned hour and minute at which the lull is
    # scheduled to end
    def lull_end_params
      { hour: 5, min: 0 }
    end
  end
end
