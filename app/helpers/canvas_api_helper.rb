# Collection of methods for parsing data returned from the Canvas API
module CanvasAPIHelper
  def concat_submission_comments(comments, separator="; ")
    return nil if comments.blank?
    comments.pluck("comment").each_with_index.map do |comment, i|
      "Comment #{i+1}: #{comment}"
    end.join(separator)
  end
end
