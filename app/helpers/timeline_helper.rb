module TimelineHelper
  def timeline_content(event)
    method = "#{event.class.name.demodulize.underscore}_timeline_content"
    self.send(method, event) if self.respond_to? method
  end

  def assignment_timeline_content(assignment)
    content = detail_link_timeline_content(assignment) || ""
    content.concat file_attachment_timeline_content(assignment.assignment_files) || ""
    content.concat raw assignment.description
  end

  def challenge_timeline_content(challenge)
    content = detail_link_timeline_content(challenge) || ""
    content.concat file_attachment_timeline_content(challenge.challenge_files) || ""
    content.concat raw challenge.description
  end

  def event_timeline_content(event)
    raw event.description
  end

  private

  def detail_link_timeline_content(model)
    if model.course.show_see_details_link_in_timeline?
      content_tag(:p) do
        content_tag(:a, "See the details", href: "#{url_for(model.class)}/#{model.id}")
      end
    end
  end

  def file_attachment_timeline_content(files)
    if files.present?
      content_tag(:ul, class: "attachments") do
        files.collect do |f|
          link_content = content_tag(:i, nil, class: "fa fa-file-o fa-fw")
          link_content.concat content_tag(:a, f.filename, href: f.url)
          concat content_tag(:li, link_content, class: "document")
        end
      end
    end
  end
end
