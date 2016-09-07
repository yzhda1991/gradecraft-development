module Services
  module Actions
    class UpdatesImportedTimestamp
      extend LightService::Action

      expects :imported_assignment

      executed do |context|
        context.imported_assignment.update_attribute :last_imported_at, DateTime.now
      end
    end
  end
end
