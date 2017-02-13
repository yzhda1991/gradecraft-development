require "rails_spec_helper"
require "./app/helpers/application_helper"

describe ApplicationHelper do
  include RSpecHtmlMatchers

  describe "#tooltip" do
    let(:tooltip_id) { "tooltip-id" }

    context "when type is icon and there is no placement specified" do
      let(:src) { :lock }

      it "renders the expected tooltip html if a block is given" do
        tooltip = helper.tooltip(tooltip_id, src) { "blah blah" }
        expect(tooltip).to have_tag "span", with: { class: "has-tooltip", "aria-describedby": "tooltip-id", tabindex: "0" } do
          with_tag "i", with: { class: "fa-lock" }
          with_tag "span", with: { class: "display-on-hover hover-style hover-style-top", id: "tooltip-id", role: "tooltip" }
        end
      end

      it "renders the expected tooltip html if no block is given" do
        tooltip = helper.tooltip(tooltip_id, src)
        expect(tooltip).to have_tag "span", with: { class: "has-tooltip", "aria-describedby": "tooltip-id", tabindex: "0" } do
          with_tag "i", with: { class: "fa-lock" }
          with_tag "span", with: { class: "display-on-hover hover-style hover-style-top", id: "tooltip-id", role: "tooltip" }
        end
      end
    end

    context "when type is icon and placement is specified" do
      let(:placement) { "right" }
      let(:src) { :lock }

      it "renders the expected tooltip html if a block is given" do
        tooltip = helper.tooltip(tooltip_id, src, placement: placement) { "blah blah" }
        expect(tooltip).to have_tag "span", with: { class: "has-tooltip", "aria-describedby": "tooltip-id", tabindex: "0" } do
          with_tag "i", with: { class: "fa-lock" }
          with_tag "span", with: { class: "display-on-hover hover-style hover-style-right", id: "tooltip-id", role: "tooltip" }
        end
      end

      it "renders the expected tooltip html if no block is given" do
        tooltip = helper.tooltip(tooltip_id, src, placement: placement)
        expect(tooltip).to have_tag "span", with: { class: "has-tooltip", "aria-describedby": "tooltip-id", tabindex: "0" } do
          with_tag "i", with: { class: "fa-lock" }
          with_tag "span", with: { class: "display-on-hover hover-style hover-style-right", id: "tooltip-id", role: "tooltip" }
        end
      end
    end

    context "when type is image without placement specified", focus: true do
      let(:src) { "http://localhost:5000/images/badge.png" }
      let(:type) {"image"}

      it "renders the expected tooltip html if a block is given" do
        tooltip = helper.tooltip(tooltip_id, src, type: type) { "blah blah" }
        expect(tooltip).to have_tag "span", with: { class: "has-tooltip", "aria-describedby": "tooltip-id", tabindex: "0" } do
          with_tag "img", with: { src: "http://localhost:5000/images/badge.png" }
          with_tag "span", with: { class: "display-on-hover hover-style hover-style-top", id: "tooltip-id", role: "tooltip" }
        end
      end

      it "renders the expected tooltip html if no block is given" do
        tooltip = helper.tooltip(tooltip_id, src, type: type)
        expect(tooltip).to have_tag "span", with: { class: "has-tooltip", "aria-describedby": "tooltip-id", tabindex: "0" } do
          with_tag "img", with: { src: "http://localhost:5000/images/badge.png" }
          with_tag "span", with: { class: "display-on-hover hover-style hover-style-top", id: "tooltip-id", role: "tooltip" }
        end
      end
    end

    context "when there is placement specified" do
      let(:src) { "http://localhost:5000/images/badge.png" }
      let(:type) {"image"}
      let(:placement) { "right" }

      it "renders tooltip if a block is given" do
        tooltip = helper.tooltip(tooltip_id, src, type: type, placement: placement) { "blah blah" }
        expect(tooltip).to have_tag "span", with: { class: "has-tooltip", "aria-describedby": "tooltip-id", tabindex: "0" } do
          with_tag "img", with: { src: "http://localhost:5000/images/badge.png" }
          with_tag "span", with: { class: "display-on-hover hover-style hover-style-right", id: "tooltip-id", role: "tooltip" }
        end
      end
    end
  end
end
