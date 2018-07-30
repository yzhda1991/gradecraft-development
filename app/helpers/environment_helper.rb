module EnvironmentHelper
  def environment_to_readable_s
    case Rails.env.to_sym
    when :production then "Umich"
    when :beta then "App"
    else
      Rails.env.capitalize
    end
  end
end
