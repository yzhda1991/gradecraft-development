module TextHelper
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
end
