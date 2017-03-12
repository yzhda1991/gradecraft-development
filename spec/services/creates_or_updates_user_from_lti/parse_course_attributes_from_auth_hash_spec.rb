describe Services::Actions::ParseCourseAttributesFromAuthHash do
  let(:auth_hash) { OmniAuth::AuthHash.new({
    extra: {
      raw_info: {
        context_id: "cosc111",
        context_label: "111",
        context_title: "Intro to Computery Things"
      }
    }})
  }

  it "expects an auth hash" do
    expect { described_class.execute }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "promises the user attributes" do
    result = described_class.execute auth_hash: auth_hash
    expect(result).to have_key :course_attributes
  end
end
