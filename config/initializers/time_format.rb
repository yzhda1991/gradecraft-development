Time::DATE_FORMATS[:default] = lambda { |time| time.strftime("%B %-e, %Y - %-l:%M%P") }
Time::DATE_FORMATS[:gt_date] = lambda { |time| time.strftime("%B %-e, %Y") }
