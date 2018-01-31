describe CopyLog do
  let(:course) { build :course }
  subject { build :copy_log, course: course }

  it "is invalid without a log" do
    subject.log = nil
    expect(subject).to_not be_valid
    expect(subject.errors[:log]).to include "can't be blank"
  end

  it "is invalid without course" do
    subject.course = nil
    expect(subject).to_not be_valid
    expect(subject.errors[:course]).to include "can't be blank"
  end

  describe "to_hash" do
    it "converts the log back to a hash" do
      expect(subject.to_hash).to eq({courses: {"1"=>"2"}})
    end
  end

  describe "parse_log" do
    it "stores the log hash as a string" do
      subject.parse_log({courses: {"2"=>"3"}})
      expect(subject.log).to eq("{:courses=>{\"2\"=>\"3\"}}")
    end
  end
end
