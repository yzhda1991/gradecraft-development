# This module is for the color_theme development page only
# and is not used in Gradecraft

module ColorPaletteHelper
  def color_block_set(color, numbers)
    numbers.collect do |number|
      class_name = "color-#{color}-#{number}"
      content_tag :div, class: "color-block-set" do
        content_tag(:div, "", class: "color-block #{class_name}") +
        content_tag(:div, ".#{class_name}", class: "color-name")
      end
    end.join("\n")
  end
end
