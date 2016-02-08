require "rails_spec_helper"

describe Criterion do
  subject { build(:criterion) }

  describe "validations" do
    it "is valid with max_points, name, and order" do
      expect(subject).to be_valid
    end

    it "is invalid without name" do
      subject.name = nil
      expect(subject).to be_invalid
    end

    it "is invalid without order" do
      subject.order = nil
      expect(subject).to be_invalid
    end
  end

  describe "#copy" do
    let(:criterion) { build :criterion }
    subject { criterion.copy }

    it "sets the default levels to false" do
      expect(subject.add_default_levels).to eq false
    end

    it "saves the copy if the criterion is copied" do
      criterion.save
      expect(subject).to_not be_new_record
    end

    it "copies the levels" do
      criterion.save
      expect(subject.levels.count).to eq 2 # default levels already there
      expect(subject.levels.map(&:criterion_id)).to eq [subject.id, subject.id]
    end
  end

  context "creation" do
    context "criterion is flagged as duplicated" do
      it "should not create levels" do
        subject.add_default_levels = false
        subject.save
        expect(subject.levels.count).to eq(0)
      end
    end

    context "criterion isn't flagged as duplicated" do
      it "should create levels" do
        subject.add_default_levels = true
        subject.save
        expect(subject.levels.count).to eq(2)
      end
    end

    context "default" do
      it "should create default levels" do
        subject = create(:criterion)
        expect(subject.levels.count).to eq(2)
      end
    end
  end
end
