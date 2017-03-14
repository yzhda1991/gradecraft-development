describe Services::Actions::CreatesCourseMembership do
  let(:course) { create :course }
  let(:user) { create :user }

  it "expects a user to create the course membership for" do
    expect { described_class.execute course: course }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "expects a course to create the course membership for" do
    expect { described_class.execute user: user }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "creates the course membership between the course and the user" do
    described_class.execute course: course, user: user
    result = CourseMembership.where(course: course, user: user).first
    expect(result).to_not be_nil
    expect(result.role).to eq "student"
  end

  it "does not create the course membership if it already exists" do
    create(:course_membership, :professor, course: course, user: user)
    described_class.execute course: course, user: user
    expect(CourseMembership.where(course: course, user: user).count).to eq 1
  end
end
