require "light-service"
require "active_record_spec_helper"
require "./app/services/creates_or_updates_user/creates_or_updates_user"

describe Services::Actions::CreatesOrUpdatesUser do
  let(:course) { create :course }
  let(:user) { build :user }
  let(:attributes) { user.attributes }

  it "expects attributes to assign to the user" do
    expect { described_class.execute course: course }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "expects course to assign to the user" do
    expect { described_class.execute attributes: attributes }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end
end
