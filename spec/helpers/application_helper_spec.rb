require "rails_spec_helper"
require "./app/helpers/application_helper"
include ActionView

describe ApplicationHelper do
  include RSpecHtmlMatchers

  describe "#icon_tooltip" do
    let(:tooltip_id) {"tooltip-id"}
    let(:icon) {:lock}

    it "it renders tooltip with icon when given" do
      icon_tooltip = helper.icon_tooltip(tooltip_id, icon) {"blah blah"}
      expect(icon_tooltip).to have_tag "span", with: { class: "has-tooltip", "aria-describedby": "tooltip-id", tabindex: "0" } do
        with_tag "i", with: { class: "fa-lock" }
        with_tag "span", with: { class: "display-on-hover hover-style hover-style-top", id: "tooltip-id", role: "tooltip"}
      end
    end
    context "tooltip with placement specified" do
      let(:placement) {"right"}

      it "adds appropriate class based on placement" do
        icon_tooltip = helper.icon_tooltip(tooltip_id, icon, placement) {"blah blah"}
        expect(icon_tooltip).to have_tag "span", with: { class: "has-tooltip", "aria-describedby": "tooltip-id", tabindex: "0" } do
          with_tag "i", with: { class: "fa-lock" }
          with_tag "span", with: { class: "display-on-hover hover-style hover-style-right", id: "tooltip-id", role: "tooltip"}
        end
      end
    end
  end
end
