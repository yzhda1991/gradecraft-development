module Services
  module Actions
    class RemovesTextCommentDraft
      extend LightService::Action

      expects :submission

      executed do |context|
        context.submission.update(text_comment_draft: nil)
      end
    end
  end
end
