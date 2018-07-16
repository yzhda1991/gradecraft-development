describe MultipliersExporter do
    let(:course) {create :course_with_weighting}
    let!(:student_1) {create :user, courses: [course], role: :student, first_name: "Yirmiyahu", last_name: "Valentin", email: "yirmiyahu.valentin@gmail.com"}
    let!(:student_2) {create :user, courses: [course], role: :student, first_name: "Loretta", last_name: "Nhung", email: "loretta.nhung@gmail.com"}
    let!(:assignment_type_1) {create :assignment_type, course: course, name: "Charms", student_weightable: true, position: 1}
    let!(:assignment_type_2) {create :assignment_type, course: course, name: "History of Wizardry", student_weightable: true, position: 2}
    let!(:assignment_type_weight_1) {create :assignment_type_weight, student: student_1, course: course, assignment_type: assignment_type_1, weight: 2}
    let!(:assignment_type_weight_2) {create :assignment_type_weight, student: student_1, course: course, assignment_type: assignment_type_2, weight: 4}

    subject { described_class.new(course) }

    describe "#export" do
        it "retrieves export headers" do
            csv = subject.export
            expect(csv).to include("First Name,Last Name,Email,Fully Assigned,Unassigned Number,Charms,History of Wizardry")
        end

        it "creates a csv with a list of all students in the course and show multipliers", focus: true do
            csv = CSV.new(subject.export).read
            expect(csv.length).to eq 3
            expect(csv[1]).to eq ["Loretta","Nhung","loretta.nhung@gmail.com","No","6","0","0"]
            expect(csv[2]).to eq ["Yirmiyahu","Valentin","yirmiyahu.valentin@gmail.com","Yes","0","2","4"]
        end
    end
end
