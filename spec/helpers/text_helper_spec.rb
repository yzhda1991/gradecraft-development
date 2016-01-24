require "rails_spec_helper"
require "./app/helpers/text_helper"

describe TextHelper do
  include RSpecHtmlMatchers

  describe "#omission_link_to" do
    let(:content) { "Bacon ipsum dolor amet corned beef turducken cupim beef ribs ribeye, salami picanha frankfurter ham leberkas pancetta. Ham hock tongue tenderloin turducken ham jowl." }

    it "creates a link with content that has omissions for content with more than 50 characters" do
      link = helper.omission_link_to(content, "http://bacon.com")
      expect(link).to have_tag("a", text: "#{content[0..47]}...")
    end

    it "does not indicate a continuation if it falls below the limit" do
      content = "I ❤️  Bacon"
      link = helper.omission_link_to(content, "http://bacon.com")
      expect(link).to have_tag("a", text: content)
    end

    it "can be limited by an option" do
      link = helper.omission_link_to(content, "http://bacon.com", limit: 25)
      expect(link).to have_tag("a", text: "#{content[0..22]}...", without: { limit: "25" })
    end

    it "can be have a different indicator other than an elipsis" do
      indicator = "🍴 🍽"
      link = helper.omission_link_to(content, "http://bacon.com", indicator: indicator)
      expect(link).to have_tag("a", text: "#{content[0..47]}#{indicator}", without: { indicator: indicator })
    end

    it "moves the original content to the title" do
      link = helper.omission_link_to(content, "http://bacon.com")
      expect(link).to have_tag("a", with: { "title" => content })
    end

    context "with content from a block" do
      it "creates a link with content that has omissions for content with more than 50 characters" do
        link = helper.omission_link_to("http://bacon.com") do content end
        expect(link).to have_tag("a", text: "#{content[0..47]}...")
      end

      it "can be limited by an option" do
        link = helper.omission_link_to("http://bacon.com", limit: 25) do content end
        expect(link).to have_tag("a", text: "#{content[0..22]}...", without: { limit: "25" })
      end

      it "does not indicate a continuation if it falls below the limit" do
        content = "I ❤️  Bacon"
        link = helper.omission_link_to("http://bacon.com") do content end
        expect(link).to have_tag("a", text: content)
      end

      it "moves the original content to the title" do
        link = helper.omission_link_to("http://bacon.com") do content end
        expect(link).to have_tag("a", with: { "title" => content })
      end
    end
  end
end
