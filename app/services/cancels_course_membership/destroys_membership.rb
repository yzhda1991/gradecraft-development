module Services
  module Actions
    class DestroysMembership
      extend LightService::Action

      expects :membership

      executed do |context|
        membership = context[:membership]
        context.skip_all! unless membership.student?
        membership.destroy
      end
    end
  end
end
