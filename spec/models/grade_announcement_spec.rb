require "rails_spec_helper"

describe GradeAnnouncement do
  let(:announcement) { Announcement.unscoped.last }
  let(:grade) { create :grade, graded_by: user }
  let(:user) { create :user }

  describe ".create" do
    skip "pending semester change"
    # it "creates an announcement for the grade" do
    #   expect { described_class.create grade }.to change { Announcement.count }.by 1
    #   expect(announcement.course).to eq grade.course
    #   expect(announcement.author).to eq grade.graded_by
    #   expect(announcement.recipient).to eq grade.student
    #   expect(announcement.title).to eq \
    #     "#{grade.course.course_number} - #{grade.assignment.name} Graded"
    #   expect(announcement.body).to include \
    #     "You can now view the grade for your #{grade.course.assignment_term.downcase} "\
    #       "#{grade.assignment.name} in #{grade.course.name}."
    #   expect(announcement.body).to include \
    #     "Visit <a href=http://localhost:5000/assignments/#{(grade.assignment.id)}>"\
    #       "#{grade.assignment.name}</a> to view your results."
    # end
  end
end
