describe Services::Actions::SavesEarnedLevelBadges do
  let(:earned_badge) { build :earned_badge }

  it "expects criterion grades passed to service" do
    expect { described_class.execute }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "saves the criterion grades" do
    result = described_class.execute earned_level_badges: [earned_badge]
    expect(result[:earned_level_badges].first).to_not be_new_record
  end

  it "halts if a record is invalid" do
    earned_badge.student_id = nil
    expect { described_class.execute earned_level_badges: [earned_badge] }.to \
      raise_error LightService::FailWithRollbackError
  end
end
