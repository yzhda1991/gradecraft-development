require "rails_spec_helper"
require "./app/helpers/history_helper"

describe HistoryHelper do
  include RSpecHtmlMatchers

  describe "#history" do
    let(:user) { create :user, first_name: "Robert", last_name: "Plant" }
    let(:single_changeset) do
      [{ "name" => ["Bob", "Jimmy"],
         "updated_at" => [DateTime.new(2015, 4, 15, 1, 20),
                          DateTime.new(2015, 4, 15, 1, 21)],
         "actor_id" => user.id }]
    end

    it "describes a changeset on an update of a single field" do
      history = helper.history single_changeset
      expect(history).to have_tag("div") do
        with_text "Robert Plant changed the name from \"Bob\" to \"Jimmy\" on April 15th, 2015 at 1:21 AM"
      end
    end

    it "describes a changeset from the current user" do
      allow(helper).to receive(:current_user).and_return user
      history = helper.history single_changeset
      expect(history).to have_tag("div") do
        with_text "You changed the name from \"Bob\" to \"Jimmy\" on April 15th, 2015 at 1:21 AM"
      end
    end

    xit "describes a changeset from a user who was deleted"
    xit "describes the creation of a model"
    xit "describes a changeset of multiple fields"
    xit "describes a changeset of a text field"
  end
end
