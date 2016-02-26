module Toolkits
  module Lib
    module LullToolkit

      def five_pm
        @five_pm ||= Time.now.change(hour: 17, min: 0)
      end

      def noon
        @noon ||= Time.now.change(hour: 12, min: 0)
      end

      def six_am
        @six_am ||= Time.now.change(hour: 6, min: 0)
      end

      def october(day_of_month)
        Time.zone.parse("Oct #{day_of_month} #{Time.now.year}")
      end

    end
  end
end
