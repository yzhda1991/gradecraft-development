module BaseToolkit
  def clear_rails_cache
    Rails.cache.clear
  end

  def create_doubles_with_ivars(*entities)
    entities.each do |entity|
      this_double = double(entity)
      instance_variable_set("@#{entity.to_s.underscore}", this_double)
    end
  end
end
