module Services
  module Actions
    class CreatesOrUpdatesUser
      extend LightService::Action

      expects :attributes, :course

      executed do |context|
      end
    end
  end
end
