describe Provider do
  subject { create :provider }

  describe "#for_course" do
    context "with a course that does not belong to an institution" do
      let(:course) { build_stubbed :course }

      it "returns nil" do
        expect(Provider.for_course course).to be_nil
      end
    end

    context "with a course that belongs to an institution" do
      let(:institution) { create :institution }
      let(:course) { create :course, institution: institution }

      context "when there are no linked providers" do
        it "returns nil" do
          expect(Provider.for_course course).to be_nil
        end
      end

      context "when there is a linked provider" do
        let!(:provider) { create :institution_provider, providee: institution }

        it "returns the provider" do
          expect(Provider.for_course course).to eq provider
        end
      end
    end
  end
end
