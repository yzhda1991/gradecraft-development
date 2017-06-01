# RSpec.describe S3Manager::Common do
#   let(:s3_manager) { S3Manager::Manager.new }
#
#   describe "master method for putting objects to S3 from a given client" do
#     let(:file_path) { Tempfile.new("some-file") }
#     let(:object_key) { "jerrys-hat" }
#     let(:encrypted_client) { s3_manager.encrypted_client }
#     let(:client) { s3_manager.client }
#     let(:put_object_with_client) { s3_manager.put_object_with_client(client, object_key, file_path) }
#
#     describe "#put_object_with_client" do
#       subject { put_object_with_client }
#
#       it "should open the file path" do
#         expect(File).to receive(:open).with(file_path, "rb")
#         subject
#       end
#
#       it "should call #put_object on the encrypted client" do
#         expect(client).to receive(:put_object)
#         subject
#       end
#
#       it "should get an AWS Seahorse object in response" do
#         expect(subject.class).to eq(Seahorse::Client::Response)
#       end
#
#       it "should have been sucessful" do
#         expect(subject.successful?).to be_truthy
#       end
#
#       it "should suggest that AES256 encryption was used" do
#         expect(subject.server_side_encryption).to eq("AES256")
#       end
#     end
#   end
# end
