require 'spec_helper'

describe BadgeFile do

  before do
    @badge = build(:badge)
    @badge_file = @badge.badge_files.new(filename: "test", file: fixture_file('test_image.jpg', 'img/jpg'))
  end

  subject { @badge_file }

  it { is_expected.to respond_to("filename")}
  it { is_expected.to respond_to("badge_id")}
  it { is_expected.to respond_to("filepath")}
  it { is_expected.to respond_to("file")}
  it { is_expected.to respond_to("file_processing")}
  it { is_expected.to respond_to("created_at")}
  it { is_expected.to respond_to("updated_at")}

  it { is_expected.to be_valid }

  describe "when filename is not present" do
    before { @badge_file.filename = nil }
    it { is_expected.not_to be_valid }
  end

  describe "as a dependency of the submission" do
    it "is saved when the parent submission is saved" do
      @badge.save!
      expect(@badge_file.badge_id).to equal @badge.id
      expect(@badge_file.new_record?).to be_falsey
    end

    it "is deleted when the parent submission is destroyed" do
      @badge.save!
      expect {@badge.destroy}.to change(BadgeFile, :count).by(-1)
    end
  end

  it "accepts text files as well as images" do
    @badge_file.file = fixture_file('test_file.txt', 'txt')
    @badge.save!
    expect expect(@badge_file.url).to match(/.*\/uploads\/badge_file\/file\/#{@badge_file.id}\/\d+_test_file\.txt/)
  end

  it "accepts multiple files" do
    @badge.badge_files.new(filename: "test", file: fixture_file('test_file.txt', 'img/jpg'))
    @badge.save!
    expect(@badge.badge_files.count).to equal 2
  end

  it "has an accessible url" do
    @badge.save!
    expect expect(@badge_file.url).to match(/.*\/uploads\/badge_file\/file\/#{@badge_file.id}\/\d+_test_image\.jpg/)
  end

  it "shortens and removes non-word characters from file names on save" do
    @badge_file.file = fixture_file('Too long, strange characters, and Spaces (In) Name.jpg', 'img/jpg')
    @badge.save!
    expect expect(@badge_file.url).to match(/.*\/uploads\/badge_file\/file\/#{@badge_file.id}\/\d+_too_long__strange_characters__and_spaces_\.jpg/)
  end
end
