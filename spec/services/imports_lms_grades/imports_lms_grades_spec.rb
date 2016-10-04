require "light-service"
require "active_record_spec_helper"
require "./app/services/imports_lms_grades/imports_lms_grades"

describe Services::Actions::ImportsLMSGrades do
  let(:assignment) { create :assignment }
  let(:grade) { Grade.unscoped.last }
  let(:grades) { [{ "id" => "GRADE_1", "score" => 97 }] }
  let(:provider) { :canvas }
  let(:user) { create :user }

  it "expects grades to import" do
    expect { described_class.execute assignment: assignment,
             provider: provider, user: user }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "expects an assignment to create the grades for" do
    expect { described_class.execute grades: grades, provider: provider, user: user }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "expects a provider to create the correct importer object" do
    expect { described_class.execute assignment: assignment, grades: grades,
             user: user }.to raise_error LightService::ExpectedKeysNotInContextError
  end

  it "expects a user to find the grade information for" do
    expect { described_class.execute assignment: assignment, grades: grades,
             provider: provider }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  context "with a user authorization" do
    let!(:user_authorization) { create :user_authorization, user: user,
                                provider: provider, access_token: "BLAH" }

    it "imports the grades" do
      allow_any_instance_of(ActiveLMS::Syllabus).to \
        receive(:user).and_return({ "primary_email" => user.email })
      result = described_class.execute assignment: assignment,
        grades: grades, provider: provider, user: user

      expect(result.grades_import_result.successful.count).to eq 1
    end
  end

  context "without a user authorization" do
    it "does not create the grade" do
      result = described_class.execute assignment: assignment,
          grades: grades, provider: provider, user: user

      expect(result.grades_import_result).to be_nil
    end
  end
end
