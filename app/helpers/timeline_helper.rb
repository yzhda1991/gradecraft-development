module TimelineHelper
  def timeline_content(event)
    method = "#{event.class.name.demodulize.underscore}_timeline_content"
    self.send(method, event) if self.respond_to? method
  end

  def assignment_timeline_content(assignment)
    content = detail_link_timeline_content(assignment) || ""
    if assignment.assignment_files.present?
      files_content = content_tag(:ul, class: "attachments") do
        assignment.assignment_files.collect do |af|
          link_content = content_tag(:i, nil, class: "fa fa-file-o fa-fw")
          link_content.concat content_tag(:a, af.filename, href: af.url)
          concat content_tag(:li, link_content, class: "document")
        end
      end
      content.concat files_content
    end
    content.concat assignment.description
  end

  def challenge_timeline_content(challenge)
    content = detail_link_timeline_content(challenge) || ""
    if challenge.challenge_files.present?
      files_content = content_tag(:ul, class: "attachments") do
        challenge.challenge_files.collect do |cf|
          link_content = content_tag(:i, nil, class: "fa fa-file-o fa-fw")
          link_content.concat content_tag(:a, cf.filename, href: cf.url)
          concat content_tag(:li, link_content, class: "document")
        end
      end
      content.concat files_content
    end
    content.concat challenge.description
  end

  def event_timeline_content(event)
    event.description
  end

  private

  def detail_link_timeline_content(model)
    if model.course.show_see_details_link_in_timeline?
      content_tag(:p) do
        content_tag(:a, "See the details", href: "#{url_for(model)}/#{model.id}")
      end
    end
  end
end
