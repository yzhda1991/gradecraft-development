require "rails_spec_helper"
require "./app/helpers/history_helper"

describe HistoryHelper do
  include RSpecHtmlMatchers

  describe "#history" do
    let(:user) { create :user, first_name: "Robert", last_name: "Plant" }

    it "describes a changeset on an update of a single field" do
      changeset = [{ "name" => ["Bob", "Jimmy"],
                     "updated_at" => [DateTime.new(2015, 4, 15, 1, 20),
                                      DateTime.new(2015, 4, 15, 1, 21)],
                     "actor_id" => user.id }]
      history = helper.history changeset
      expect(history).to have_tag("div") do
        with_text "Robert Plant changed the name from \"Bob\" to \"Jimmy\" on April 15th, 2015 at 1:21 AM"
      end
    end
  end
end
