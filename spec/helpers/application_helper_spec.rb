require "rails_spec_helper"
require "./app/helpers/application_helper"

describe ApplicationHelper do
  include RSpecHtmlMatchers

  describe "#icon_tooltip" do
    let(:tooltip_id) { "tooltip-id" }
    let(:icon) { :lock }

    context "when there is no placement specified" do
      it "renders the expected elements if a block is given" do # this should describe the test, but I'm iffy about the wording here
        icon_tooltip = helper.icon_tooltip(tooltip_id, icon) { "blah blah" }
        expect(icon_tooltip).to have_tag "span", with: { class: "has-tooltip", "aria-describedby": "tooltip-id", tabindex: "0" } do
          with_tag "i", with: { class: "fa-lock" }
          with_tag "span", with: { class: "display-on-hover hover-style hover-style-top", id: "tooltip-id", role: "tooltip" }
        end
      end

      it "renders the expected elements if no block is given" do
        icon_tooltip = helper.icon_tooltip(tooltip_id, icon) { }
        expect(icon_tooltip).to have_tag "span", with: { class: "has-tooltip", "aria-describedby": "tooltip-id", tabindex: "0" } do
          with_tag "i", with: { class: "fa-lock" }
          with_tag "span", with: { class: "display-on-hover hover-style hover-style-top", id: "tooltip-id", role: "tooltip" }
        end
      end
    end

    context "when there is placement specified" do
      let(:placement) { "right" }

      it "renders the expected elements if a block is given" do
        icon_tooltip = helper.icon_tooltip(tooltip_id, icon, placement) { "blah blah" }
        expect(icon_tooltip).to have_tag "span", with: { class: "has-tooltip", "aria-describedby": "tooltip-id", tabindex: "0" } do
          with_tag "i", with: { class: "fa-lock" }
          with_tag "span", with: { class: "display-on-hover hover-style hover-style-right", id: "tooltip-id", role: "tooltip" }
        end
      end

      it "renders the expected elements if no block is given" do
        icon_tooltip = helper.icon_tooltip(tooltip_id, icon, placement) { }
        expect(icon_tooltip).to have_tag "span", with: { class: "has-tooltip", "aria-describedby": "tooltip-id", tabindex: "0" } do
          with_tag "i", with: { class: "fa-lock" }
          with_tag "span", with: { class: "display-on-hover hover-style hover-style-right", id: "tooltip-id", role: "tooltip" }
        end
      end
    end
  end
end
