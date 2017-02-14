module IconHelper

  def glyph(icon_name, hash={})
    content_tag :i, nil, hash.merge(class: "fa fa-fw fa-#{icon_name}")
  end

  def decorative_glyph(icon_name, hash={})
    content_tag :i, nil, hash.merge(class: "fa fa-fw fa-#{icon_name}", "aria-hidden": "true")
  end

end
