require "active_lms"

module Services
  module Actions
    class RetrievesLMSUsers
      extend LightService::Action

      expects :access_token, :provider, :user_ids
      promises :users

      executed do |context|
        provider = context.provider
        access_token = context.access_token
        user_ids = context.user_ids

        context.users = []

        syllabus = ActiveLMS::Syllabus.new provider, access_token
        user_ids.each do |user_id|
          context.users << syllabus.user(user_id)
        end
      end
    end
  end
end
