module HumanHistory
  class ActorHistoryToken
    attr_reader :user_id

    def initialize(_, value, _)
      @user_id = value
    end

    def parse(options={})
      current_user = options[:current_user]
      name = "You" if current_user && current_user.id.to_s == user_id.to_s
      name ||= User.where(id: user_id).first.try(:name)
      name ||= "Someone"
      { self.class.token => name }
    end

    class << self
      def token
        :actor
      end

      def tokenizable?(key, _, _)
        key == "actor_id"
      end
    end
  end
end
