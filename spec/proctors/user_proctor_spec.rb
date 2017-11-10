describe UserProctor do
  let(:user) { build_stubbed :user }
  let(:subject) { described_class.new user }

  describe "#can_update_password?" do
    let(:course) { build_stubbed :course }
    let(:proxy) { build_stubbed :user, courses: [course] }

    it "returns false if the user has a kerberos password" do
      user.kerberos_uid = Faker::Internet.unique.user_name
      expect(subject.can_update_password? proxy, course).to eq false
    end

    it "returns false if the user has not been persisted" do
      expect(subject.can_update_password? proxy, course).to eq false
    end

    context "as an admin" do
      let(:proxy) { build_stubbed :user, courses: [course], role: :admin }

      it "returns true" do
        expect(subject.can_update_password? proxy, course).to eq true
      end
    end

    context "as an instructor" do
      let(:user) { create :user }
      let(:institution) { build_stubbed :institution, :k_12 }
      let(:proxy) { build_stubbed :user, courses: [course], role: :professor }

      it "returns true if the environment is beta and the linked institution is K-12" do
        allow(Rails).to receive(:env).and_return ActiveSupport::StringInquirer.new("beta")
        course.institution = institution
        expect(subject.can_update_password? proxy, course).to eq true
      end
    end
  end
end
