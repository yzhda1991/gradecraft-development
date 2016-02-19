module Toolkits
  module EventLoggers
    module EventSession

      def define_event_session
        let(:course) { build(:course) }
        let(:user) { build(:user) }
        let(:student) { build(:user) }
        let(:request) { double(:request) }

        let(:event_session) {{
          course: course,
          user: user,
          student: student,
          request: request
        }}
      end

    end
  end
end
