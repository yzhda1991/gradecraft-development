require "rails_spec_helper"
require "./app/helpers/history_helper"

describe HistoryHelper do
  include RSpecHtmlMatchers

  describe "#history" do
    let(:user) { create :user, first_name: "Robert", last_name: "Plant" }
    let(:single_changeset) do
      [{ "first_name" => ["Bob", "Jimmy"],
         "updated_at" => [DateTime.new(2015, 4, 15, 1, 20),
                          DateTime.new(2015, 4, 15, 1, 21)],
         "event" => "update",
         "object" => "User",
         "actor_id" => user.id }]
    end
    let(:multiple_changeset) do
      [{ "first_name" => ["Bob", "Jimmy"],
         "last_name" => ["Pig", "Page"],
         "updated_at" => [DateTime.new(2015, 4, 15, 1, 20),
                          DateTime.new(2015, 4, 15, 1, 21)],
         "event" => "update",
         "object" => "User",
         "actor_id" => user.id }]
    end
    let(:created_changeset) do
      [{ "first_name" => [nil, "Bob"],
         "updated_at" => [nil, DateTime.new(2015, 4, 15, 1, 21)],
         "created_at" => [nil, DateTime.new(2015, 4, 15, 1, 21)],
         "event" => "create",
         "object" => "User",
         "actor_id" => user.id }]
    end

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
end
