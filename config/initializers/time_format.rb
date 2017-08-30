Time::DATE_FORMATS[:default] = lambda { |time| time.strftime("%A, %B %d, %Y, %l:%M%p %Z") }
Time::DATE_FORMATS[:gt_date] = lambda { |time| time.strftime("%B %-e, %Y") }
