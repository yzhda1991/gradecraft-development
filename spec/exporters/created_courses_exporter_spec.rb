describe CreatedCoursesExporter do
  describe "#export" do
    subject { described_class.new }

    context "when there are courses that were created within the timeframe" do
      let(:past_course) { create :course, course_number: 600, semester: "Spring", year: 2018, name: "Clojure", created_at: 2.months.ago }
      let(:recent_course) { create :course, year: 2018, course_number: 101, semester: "Fall", name: "Python" }
      let(:another_recent_course) { create :course, year: 2018, course_number: 211, semester: "Winter", name: "Ruby" }
      let!(:student) { create :user, courses: [recent_course, another_recent_course, past_course], role: :student, first_name: "John", last_name: "Doe" }
      let!(:staff) { create :user, courses: [recent_course, past_course], role: :professor, first_name: "Jane", last_name: "Doe", email: "jane.doe@gmail.com" }

      context "when no created from date is provided" do
        it "returns a csv containing all courses created within the last month" do
          csv = CSV.new(subject.export).read
          expect(csv.length).to eq 3
          expect(csv[1]).to eq ["101 Python Fall 2018", "1", "Yes",
            recent_course.created_at.to_formatted_s, "Jane Doe (jane.doe@gmail.com)"]
          expect(csv[2]).to eq ["211 Ruby Winter 2018", "1", "Yes",
            another_recent_course.created_at.to_formatted_s, ""]
        end
      end

      context "when a created from date is provided" do
        subject { described_class.new 3.months.ago }

        it "returns a csv containing all courses created within the given timeframe" do
          csv = CSV.new(subject.export).read
          expect(csv.length).to eq 4
          expect(csv[1]).to eq ["101 Python Fall 2018", "1", "Yes",
            recent_course.created_at.to_formatted_s, "Jane Doe (jane.doe@gmail.com)"]
          expect(csv[2]).to eq ["211 Ruby Winter 2018", "1", "Yes",
            another_recent_course.created_at.to_formatted_s, ""]
          expect(csv[3]).to eq ["600 Clojure Spring 2018", "1", "Yes",
            past_course.created_at.to_formatted_s, "Jane Doe (jane.doe@gmail.com)"]
        end
      end
    end

    context "when there are no courses that were created within the timeframe" do
      it "generates a blank csv" do
        csv = subject.export
        expect(csv).to include "Course Name", "Student Count", "Published?", "Created At", "Staff Emails"
      end
    end
  end
end
