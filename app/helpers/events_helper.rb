module EventsHelper 

  # helpers for performing various tasks relative to the nightly lull
  module Lull
    LULL_START_PARAMS = {hour: 2, min: 30}
    LULL_END_PARAMS = {hour: 5, min: 0}

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
      if is_after_todays_lull?
        tomorrows_lull_start
      else
        todays_lull_start
      end
    end

    def tomorrows_lull_start
      DateTime.tomorrow.to_time.change lull_start
    end

    def todays_lull_end
      Time.now.change(LULL_END_PARAMS)
    end

    def todays_lull_start
      Time.now.change(LULL_START_PARAMS)
    end
  end
end
