require "active_lms"

module Services
  module Actions
    class RetrievesLMSUsersWithRoles
      extend LightService::Action

      expects :access_token, :provider, :course_id
      promises :users

      executed do |context|
        provider = context.provider
        access_token = context.access_token
        course_id = context.course_id

        context.users = []

        syllabus = ActiveLMS::Syllabus.new provider, access_token
        context.users << syllabus.users(course_id, true)[:data]
      end
    end
  end
end
