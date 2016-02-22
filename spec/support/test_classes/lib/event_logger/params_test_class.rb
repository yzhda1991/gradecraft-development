class EventLoggerParamsTestClass
  extend EventLogger::Params

  numerical_params :werewolf, :badger, { :war_machine => :panzer_tank }

  def params
  end
end
