require "rails_spec_helper"

describe TimelineHelper do
  include RSpecHtmlMatchers

  describe "#timeline_content" do
    context "for an assignment" do
      let(:assignment) { build(:assignment) }

      it "calls the appropriate method based on the type" do
        expect(helper).to receive(:assignment_timeline_content).with(assignment)
        helper.timeline_content(assignment)
      end
    end
  end

  describe "#assignment_timeline_content" do
    let(:assignment) { build(:assignment) }

    it "displays a link for the details if the course calls for it" do
      allow(assignment).to receive(:id).and_return 123
      html = helper.assignment_timeline_content(assignment)
      expect(html).to have_tag "a", with: { href: assignment_path(assignment) } do
        with_text "See the details"
      end
    end

    it "does not display a link for the details if the course does not allow it" do
      allow(assignment).to receive(:id).and_return 123
      allow(assignment.course).to receive(:show_see_details_link_in_timeline?).and_return false
      allow(assignment).to receive(:description).and_return ""
      html = helper.assignment_timeline_content(assignment)
      expect(html).to be_empty
    end

    it "displays any attachments" do
      allow(assignment).to receive(:id).and_return 123
      document1 = double(:attachment, filename: "Document1.png", url: "http://example.com/document1")
      allow(assignment).to receive(:assignment_files).and_return [document1]
      html = helper.assignment_timeline_content(assignment)
      expect(html).to have_tag "ul", with: { class: "attachments" }
      expect(html).to have_tag "li", with: { class: "document" }
      expect(html).to have_tag "a", with: { href: "http://example.com/document1" } do
        with_text "Document1.png"
      end
    end

    it "displays the description if it's present" do
      allow(assignment).to receive(:id).and_return 123
      allow(assignment).to receive(:description).and_return "This is a description"
      html = helper.assignment_timeline_content(assignment)
      expect(html).to have_text "This is a description"
    end
  end
end
