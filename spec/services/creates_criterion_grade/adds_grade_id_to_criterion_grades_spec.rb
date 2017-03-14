describe Services::Actions::AddsGradeIdToCriterionGrades do
  let(:crt_grade) { build :criterion_grade }
  let(:grade) { double :grade, id: 777 }

  it "expects criterion grades passed to service" do
    expect { described_class.execute grade: grade }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "expects grade passed to service" do
    expect { described_class.execute criterion_grades: [crt_grade] }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "adds the grade id to the criterion grades" do
    result = described_class.execute criterion_grades: [crt_grade], grade: grade
    expect(result[:criterion_grades].first.grade_id).to eq(777)
  end
end
