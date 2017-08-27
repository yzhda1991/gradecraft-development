describe HistoryHelper do
  include RSpecHtmlMatchers

  let(:user) { create :user, first_name: "Robert", last_name: "Plant" }
  let(:single_changeset) do
    [{ "first_name" => ["Bob", "Jimmy"],
       "event" => "update",
       "object" => "User",
       "recorded_at" => DateTime.new(2015, 4, 15, 1, 21),
       "actor_id" => user.id }]
  end
  let(:multiple_changeset) do
    [{ "first_name" => ["Bob", "Jimmy"],
       "last_name" => ["Pig", "Page"],
       "event" => "update",
       "object" => "User",
       "recorded_at" => DateTime.new(2015, 4, 15, 1, 21),
       "actor_id" => user.id }]
  end
  let(:created_changeset) do
    [{ "first_name" => [nil, "Bob"],
       "updated_at" => [nil, DateTime.new(2015, 4, 15, 1, 21)],
       "created_at" => [nil, DateTime.new(2015, 4, 15, 1, 21)],
       "event" => "create",
       "object" => "User",
       "recorded_at" => DateTime.new(2015, 4, 15, 1, 21),
       "actor_id" => user.id }]
  end

  describe "#history" do
    it "describes a changeset on an update of a single field" do
      history = helper.history single_changeset
      expect(history).to have_tag("div") do
        with_text "Robert Plant changed the first name from \"Bob\" to \"Jimmy\" on April 15th, 2015 at 1:21 AM"
      end
    end

    it "describes a changeset from the current user" do
      allow(helper).to receive(:current_user).and_return user
      history = helper.history single_changeset
      expect(history).to have_tag("div") do
        with_text "You changed the first name from \"Bob\" to \"Jimmy\" on April 15th, 2015 at 1:21 AM"
      end
    end

    it "describes a changeset from a user who was deleted" do
      user.delete
      history = helper.history single_changeset
      expect(history).to have_tag("div") do
        with_text "Someone changed the first name from \"Bob\" to \"Jimmy\" on April 15th, 2015 at 1:21 AM"
      end
    end

    it "describes the creation of a model" do
      history = helper.history created_changeset
      expect(history).to have_tag("div") do
        with_text "Robert Plant created the user on April 15th, 2015 at 1:21 AM"
      end
    end

    it "describes a changeset of multiple fields" do
      history = helper.history multiple_changeset
      expect(history).to have_tag("div") do
        with_text "Robert Plant changed the first name from \"Bob\" to \"Jimmy\" and the last name from \"Pig\" to \"Page\" on April 15th, 2015 at 1:21 AM"
      end
    end
  end

  describe "#history_timeline" do
    it "wraps everything in a history-timeline section" do
      history = helper.history_timeline single_changeset
      expect(history).to have_tag("section#history-timeline")
    end

    it "renders a block for each changeset" do
      history = helper.history_timeline (single_changeset + multiple_changeset).flatten
      expect(history).to have_tag("div.timeline-block", count: 2)
    end

    it "renders an icon for each changeset" do
      history = helper.history_timeline single_changeset
      expect(history).to have_tag("div.timeline-user")
      expect(history).to have_tag("i.icon-user")
    end

    it "renders the appropriate header based on the changeset's object and action" do
      history = helper.history_timeline single_changeset
      expect(history).to have_tag("div.timeline-content") do
        with_tag "h2", text: "User updated"
      end
    end

    it "renders the appropriate date for the timeline" do
      history = helper.history_timeline single_changeset
      expect(history).to have_tag("div.timeline-content") do
        with_tag "span", text: "Wednesday, April 15, 2015,  1:21AM +00:00"
      end
    end

    it "renders a list of changes for each changeset" do
      history = helper.history_timeline multiple_changeset
      expect(history).to have_tag("div.timeline-content") do
        with_tag "li", text: "Robert Plant changed the first name from \"Bob\" to \"Jimmy\""
        with_tag "li", text: "Robert Plant changed the last name from \"Pig\" to \"Page\""
      end
    end

    it "renders the changes as html_safe" do
      multiple_changeset.first.merge!("profile" => [nil, "I am <strong>awesome</strong>!"])
      history = helper.history_timeline multiple_changeset
      expect(history).to have_tag("div.timeline-content") do
        with_tag "li", text: "Robert Plant changed the profile to \"I am awesome!\""
      end
    end
  end
end
