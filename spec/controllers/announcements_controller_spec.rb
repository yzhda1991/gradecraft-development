require 'spec_helper'

describe AnnouncementsController do
  describe "GET #index" do
    it "lists the announcements that are available for that course" do
      get :index
    end
  end
end
