require 'spec_helper'

describe ChallengeFile do

  before do
    @challenge = build(:challenge)
    @challenge_file = @challenge.challenge_files.new(filename: "test", file: fixture_file('test_image.jpg', 'img/jpg'))
  end

  subject { @challenge_file }

  it { is_expected.to respond_to("filename")}
  it { is_expected.to respond_to("challenge_id")}
  it { is_expected.to respond_to("filepath")}
  it { is_expected.to respond_to("file")}
  it { is_expected.to respond_to("file_processing")}
  it { is_expected.to respond_to("created_at")}
  it { is_expected.to respond_to("updated_at")}

  it { is_expected.to be_valid }

  describe "when filename is not present" do
    before { @challenge_file.filename = nil }
    it { is_expected.not_to be_valid }
  end

  describe "as a dependency of the submission" do
    it "is saved when the parent submission is saved" do
      @challenge.save!
      expect(@challenge_file.challenge_id).to equal @challenge.id
      expect(@challenge_file.new_record?).to be_falsey
    end

    it "is deleted when the parent submission is destroyed" do
      @challenge.save!
      expect {@challenge.destroy}.to change(ChallengeFile, :count).by(-1)
    end
  end

  it "accepts text files as well as images" do
    @challenge_file.file = fixture_file('test_file.txt', 'txt')
    @challenge.save!
    expect expect(@challenge_file.url).to match(/.*\/uploads\/challenge_file\/file\/#{@challenge_file.id}\/\d+_test_file\.txt/)
  end

  it "accepts multiple files" do
    @challenge.challenge_files.new(filename: "test", file: fixture_file('test_file.txt', 'img/jpg'))
    @challenge.save!
    expect(@challenge.challenge_files.count).to equal 2
  end

  it "has an accessible url" do
    @challenge.save!
    expect expect(@challenge_file.url).to match(/.*\/uploads\/challenge_file\/file\/#{@challenge_file.id}\/\d+_test_image\.jpg/)
  end

  it "shortens and removes non-word characters from file names on save" do
    @challenge_file.file = fixture_file('Too long, strange characters, and Spaces (In) Name.jpg', 'img/jpg')
    @challenge.save!
    expect expect(@challenge_file.url).to match(/.*\/uploads\/challenge_file\/file\/#{@challenge_file.id}\/\d+_too_long__strange_characters__and_spaces_\.jpg/)
  end
end
