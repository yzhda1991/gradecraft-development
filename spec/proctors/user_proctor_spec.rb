include UniMock::StubRails

describe UserProctor do
  let(:course) { create :course }
  let(:user) { instance_double "User", persisted?: true, kerberos_uid: nil }
  let(:subject) { described_class.new user }

  describe "#can_update_password?" do
    let(:proxy) { create :user, courses: [course], role: :student }

    it "returns false if the user has a kerberos password" do
      allow(user).to receive(:kerberos_uid).and_return "blah"
      expect(subject.can_update_password? proxy, course).to eq false
    end

    it "returns false if the user has not been persisted" do
      expect(subject.can_update_password? proxy, course).to eq false
    end

    context "as an admin" do
      let!(:proxy) { create :user, courses: [course], role: :admin }

      it "returns true" do
        expect(subject.can_update_password? proxy, course).to eq true
      end
    end

    context "as an instructor" do
      let(:user) { create :user }
      let(:institution) { build_stubbed :institution, :k_12 }
      let(:proxy) { create :user, courses: [course], role: :professor }

      it "returns true if the environment is beta and the linked institution is K-12" do
        allow(Rails).to receive(:env).and_return ActiveSupport::StringInquirer.new("beta")
        course.institution = institution
        expect(subject.can_update_password? proxy, course).to eq true
      end
    end
  end

  describe "#can_set_email?" do
    let(:proxy) { build :user }

    before(:each) { stub_env "production" }

    it "returns true if the user is an admin for the course" do
      create :course_membership, :admin, course: course, user: proxy
      expect(subject.can_set_email? proxy, course).to eq true
    end

    it "returns true if the environment is not production" do
      stub_env "beta"
      expect(subject.can_set_email? proxy, course).to eq true
    end
  end
end
