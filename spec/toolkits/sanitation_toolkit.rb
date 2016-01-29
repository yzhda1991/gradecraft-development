RSpec.shared_examples "a model that needs sanitation" do |attribute|
  describe "basic html sanitization" do
    describe "##{attribute}" do
      def get(attribute)
        subject.send attribute
      end

      def set(attribute, value)
        subject.send "#{attribute}=", value
      end

      it "does not allow images before saving" do
        set attribute, "This is an image <img src='test.jpg' />, ok."
        subject.save
        expect(get attribute).to eq "This is an image , ok."
      end

      it "does not allow tables before saving" do
        set attribute, "This is a table <table></table>, ok."
        subject.save
        expect(get attribute).to eq "This is a table , ok."
      end

      it "adds a no-follow attribute to links" do
        set attribute, "This is a link <a href=\"gradecraft.com\">GradeCraft</a>, ok."
        subject.save
        expect(get attribute).to \
          eq "This is a link <a href=\"gradecraft.com\" rel=\"nofollow\">GradeCraft</a>, ok."
      end
    end
  end
end
