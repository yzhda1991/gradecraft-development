module Services
  module Actions
    class RemovesTextCommentDraft
      extend LightService::Action

      expects :submission

      executed do |context|
        context.submission.text_comment_draft = nil
        context.submission.save
      end
    end
  end
end
