# RSpec.describe RandomFile::TextFile do
#   let(:rando_file_path) { Tempfile.new("rando-file").path }
#   let(:random_file) { RandomFile::TextFile.new(rando_file_path) }

#   describe "#initialize" do
#     describe "requiring a file path" do
#       context "no file path is given" do
#         subject { RandomFile::TextFile.new }
#         it "returns an error" do
#           expect { subject }.to raise_error(ArgumentError)
#         end
#       end

#       context "file path is given" do
#         subject { random_file }

#         it "creates the RandomFile::TextFile" do
#           expect(subject.class).to eq(RandomFile::TextFile)
#         end

#         it "sets the file path to @file_path" do
#           expect(subject.instance_variable_get(:@file_path)).to eq(rando_file_path)
#         end
#       end
#     end
#   end

#   describe "#file_path" do
#     subject { random_file.file_path }

#     it "should return the file_path" do
#       expect(subject).to eq(rando_file_path)
#     end
#   end

#   describe "#random_string" do
#     subject { random_file.random_string }

#     it "consists entirely of uppercase letters" do
#       expect(subject).to match(/^[A-Z]+$/)
#     end

#     it "defaults to a 10000 character threshold (between 10,000 and 20,000)" do
#       expect(10000..20000).to include(subject.size)
#     end

#     it "changes @random_string to the result of #random_string" do
#       expect(subject).to eq(random_file.instance_variable_get(:@random_string))
#     end

#     describe "setting a custom threshold" do
#       subject { random_file.random_string(40) }
#       it "accepts a custom threshold" do
#         expect(40..80).to include(subject.size)
#       end
#     end
#   end

#   describe "#write" do
#     subject { random_file.write }
#     it "writes the contents of the random string to a file at the file_path", :unreliable do
#       subject
#       expect(random_file.read.first).to eq(random_file.instance_variable_get(:@random_string) +"\n")
#     end
#   end

#   describe "#read" do
#     subject { random_file.read }
#     before { random_file.write }

#     it "writes the contents of the random string to a file at the file_path" do
#       expect(File).to receive(:readlines).with(random_file.instance_variable_get(:@file_path))
#       subject
#     end
#   end

#   describe "#size" do
#     subject { random_file.size }
#     it "returns the size of the file on disk" do
#       expect(subject).to eq(File.stat(random_file.file_path).size)
#     end
#   end

#   describe "#delete" do
#     subject { random_file.delete }
#     it "removes the file from disk" do
#       random_file.write
#       subject
#       expect(random_file.exist?).to be_falsey
#     end
#   end

#   describe "#exist?" do
#     subject { random_file.exist? }
#     before(:each) { random_file.write }

#     context "the file does not exist on disk" do
#       it "should be false" do
#         random_file.delete
#         expect(subject).to be_falsey
#       end
#     end

#     context "the file exists on disk" do
#       it "should be true" do
#         expect(subject).to be_truthy
#       end
#     end
#   end
# end
