module TimelineHelper
  def timeline_content(event)
    method = "#{event.class.name.demodulize.underscore}_timeline_content"
    self.send(method, event) if self.respond_to? method
  end

  def assignment_timeline_content(assignment)
    content = ""
    if assignment.course.show_see_details_link_in_timeline?
      content = content_tag(:p) do
        content_tag(:a, "See the details", href: assignment_path(assignment))
      end
    end
    if assignment.assignment_files.present?
      files_content = content_tag(:ul, class: "attachments") do
        assignment.assignment_files.collect do |af|
          concat content_tag(:li, content_tag(:a, af.filename, href: af.url), class: "document")
        end
      end
      content.concat files_content
    end
    content.concat assignment.description
  end

  def challenge_timeline_content(challenge)
  end

  def event_timeline_content(event)
    event.description
  end
end
