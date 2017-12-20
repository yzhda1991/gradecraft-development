require "uri"

module LinkHelper
  def external_link_to(name = nil, options = nil, html_options = nil, &block)
    if block_given?
      options = { "target" => "_blank" }.merge(options || {}) if external_link? name
    else
      html_options = { "target" => "_blank" }.merge(html_options || {}) if external_link? options
    end

    link_to name, options, html_options, &block
  end

  def external_link?(uri)
    UriInspector.new(uri).external?
  end

  def sanitize_external_links(content)
    sanitize content, scrubber: InternalLinkScrubber.new
  end

  def omission_link_to(name = nil, options = nil, html_options = nil, &block)
    omission_options = (block_given? ? options : html_options) || {}
    limit = omission_options.delete(:limit) { 50 }
    indicator = omission_options.delete(:indicator) { "..." }

    content = block_given? ? capture(&block) : name
    original_content = content.html_safe
    content = "#{content[0..(limit - indicator.length)]}#{indicator}" if content.length > limit

    if block_given?
      block = lambda { content } if block_given?
      options = { "title" => original_content }.merge(options || {})
    else
      name = content
      html_options = { "title" => original_content }.merge(html_options || {})
    end

    link_to name, options, html_options, &block
  end

  # Conditionally renders a link_to helper based on whether the course is active
  # or not - tag allows you to optionally wrap value in html tag
  def active_course_link_to(name = nil, options = nil, html_options = nil, tag_class = nil, &block)
    return unless current_user_is_admin? || current_course.active?
    content_tag(:li, class: tag_class) do
      link_to name, options, html_options, &block
    end
  end

  def edit_group_grade_link_to(assignment, group, options={})
    confirm_message = 'These grades are about to be marked as ungraded and unavailable to the students - they won\'t be visible again until you click "Submit" - are you sure?'
    options.merge! data: { confirm:  confirm_message }
    link_to decorative_glyph(:edit) + "Edit Group Grades", grade_assignment_group_path(assignment, group), options
  end

  def edit_grade_link_to(grade, options={})
    return unless current_user_is_admin? || current_course.active?
    confirm_message = 'This grade is about to be marked as ungraded and unavailable to the student - it won\'t be visible again until you click "Submit" - are you sure?'
    if grade.assignment.accepts_submissions? && grade.submission && grade.submission.resubmitted?
      options.merge! data: { confirm:  confirm_message }
      link_to decorative_glyph(:edit) + "Re-grade", edit_grade_path(grade), options
    elsif grade.student_visible?
      options.merge! data: { confirm:  confirm_message }
      link_to decorative_glyph(:edit) + "Edit", edit_grade_path(grade), options
    else
      link_to decorative_glyph(:edit) + "Edit", edit_grade_path(grade), options
    end
  end

  def active_course_link_to_unless_current(name, options = {}, html_options = {}, &block)
    link_to_unless_current name, options, html_options, &block if current_user_is_admin? || current_course.active?
  end

  class InternalLinkScrubber < Rails::Html::PermitScrubber
    def scrub(node)
      return super unless (node.type == Nokogiri::XML::Node::ELEMENT_NODE) &&
        (node.name == "a") || node.name == "iframe"
      node.set_attribute("target", "_blank") if UriInspector.new(node["href"]).external?
    end
  end

  class UriInspector
    attr_reader :uri

    def initialize(uri)
      @uri = uri
    end

    def external?
      return false if self.uri.blank?
      uri = URI(self.uri)
      uri.scheme == "mailto" ||
        (!uri.relative? &&
         (uri.host.present? &&
         !uri.host.end_with?("gradecraft.com") &&
         !uri.host.end_with?("localhost")))
    rescue URI::InvalidURIError
      false
    end
  end
end
