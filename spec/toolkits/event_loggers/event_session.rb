module Toolkits
  module EventLoggers
    module EventSession

      def define_event_session
        let(:course) { build(:course) }
        let(:user) { build(:user) }
        let(:student) { build(:user) }

        let(:event_session) {{
          course: course,
          user: user,
          student: student,
          request: request
        }}
      end

      def define_event_session_with_request
        define_event_session
        let(:request) { double(:request) }
      end

    end
  end
end
