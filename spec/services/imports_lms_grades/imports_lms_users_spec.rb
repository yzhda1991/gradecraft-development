require "spec_helper"
require "./app/services/imports_lms_grades/imports_lms_users"

describe Services::Actions::ImportsLMSUsers do
  let(:course) { create :course }
  let(:provider) { :canvas }
  let(:student) { User.unscoped.last }
  let(:users) { [{ "id" => "USER_1",
                   "primary_email" => "jimmy@example.com",
                   "name" => "Jimmy Page" }] }

  it "expects users to import" do
    expect { described_class.execute course: course, provider: provider }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "expects a course to assign to the users" do
    expect { described_class.execute provider: provider, users: users }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "expects a provider to create the correct importer object" do
    expect { described_class.execute course: course, users: users }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "creates the students" do
    result = described_class.execute course: course,
      provider: provider, users: users

    expect(result.users_import_result.successful.count).to eq 1
    expect(result.users_import_result.successful.first).to eq student
  end
end
