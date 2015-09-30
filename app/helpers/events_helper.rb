module EventsHelper 

  # helpers for performing various tasks relative to the nightly lull
  module Lull
    def time_until_next_lull
      next_lull_start - Time.now
    end

    def is_before_todays_lull?
      Time.now < todays_lull_start
    end

    def is_after_todays_lull?
      Time.now > todays_lull_end
    end

    def is_during_todays_lull?
      Time.now > todays_lull_start and
      Time.now < todays_lull_end
    end

    def next_lull_start
      is_after_todays_lull? ? tomorrows_lull_start : todays_lull_start
    end

    def tomorrows_lull_start
      Date.tomorrow.to_time.change(lull_start_params)
    end

    def todays_lull_end
      Time.now.change(lull_end_params)
    end

    def todays_lull_start
      Time.now.change(lull_start_params)
    end

    def lull_start_params
      {hour: 2, min: 30}
    end

    def lull_end_params
      {hour: 5, min: 0}
    end
  end
end
