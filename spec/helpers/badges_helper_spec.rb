describe BadgesHelper do
  include RSpecHtmlMatchers

  describe "#sidebar_earned_badge" do
    let(:badge) { double(:badge, name: "badgy", icon: "badge.png", is_unlockable?: false, full_points: nil) }
    let(:student) { double(:user) }

    it "renders an empty anchor" do
      html = helper.sidebar_earned_badge(badge, student)
      expect(html).to have_tag "a"
    end

    it "renders the image for the badge" do
      html = helper.sidebar_earned_badge(badge, student)
      expect(html).to have_tag "img", with: { class: "earned", alt: "You have earned the badgy badge" }
      expect(html).to have_css "img[src*='/assets/badge']"
    end

    it "renders an unlock icon if it's unlocked by the student" do
      allow(badge).to receive(:is_unlockable?).and_return true
      allow(badge).to receive(:is_unlocked_for_student?).with(student).and_return true
      html = helper.sidebar_earned_badge(badge, student)
      expect(html).to have_tag "i", with: { class: "fa-unlock-alt" }
    end

    it "renders a lock icon if it's unlockable but not yet unlocked" do
      allow(badge).to receive(:is_unlockable?).and_return true
      allow(badge).to receive(:is_unlocked_for_student?).with(student).and_return false
      html = helper.sidebar_earned_badge(badge, student)
      expect(html).to have_tag "i", with: { class: "fa-lock" }
    end

    it "renders the badge name in a hover state" do
      html = helper.sidebar_earned_badge(badge, student)
      expect(html).to have_tag "div", with: { class: "display-on-hover" } do
        with_text "badgy"
      end
    end

    it "renders the points earned if it has points" do
      allow(badge).to receive(:full_points).and_return 10_000
      html = helper.sidebar_earned_badge(badge, student)
      expect(html).to have_tag "div", with: { class: "display-on-hover" } do
        with_text "badgy, 10,000 points"
      end
    end
  end
end
